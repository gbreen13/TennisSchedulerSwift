//
//  schedule.swift
//  TennisSchedulerSwift
//
//  Created by George Breen on 9/19/19.
//  Copyright © 2019 George Breen. All rights reserved.
//

import Foundation


class Schedule: Codable, CustomStringConvertible {
    var startDate: Date?        // date of first week
    var endDate: Date?          // date of last week inclusive
    var courtMinutes: Int?      // how long is court time each week
    var playWeeks: [PlayWeek]?
    var blockedDays: [Date]?    // weeks courts are closed (e.g. Thanksgiving)
    var players:[Player]?       // all of the members
    var isBuilt: Bool = false   // is it built?
    
    enum CodingKeys: CodingKey {
        case startDate, endDate, courtMinutes, playWeeks, blockedDays, players
    }
    
    var description: String {
        var s: String = ""
        
        if players != nil {
            for player in players!  {
                s += "\(String(describing: player))\n"
            }
            s += "\n"
        }
        if playWeeks != nil {
            for pw in playWeeks! {
                s += "\(String(describing: pw))"
            }
            s += "\n"
        }
        return s
    }
    
    enum ScheduleError: Error {
        case noStartDate(String)
        case noEndDate(String)
        case startDateAfterEndDate(String)
    }
    
    func FindPlayer(name: String) ->Player? {
        for p in self.players! {
            if p.name == name {
                return p;
            }
        }
        return nil
    }
 // MARK: Init
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var when: String? = try (container.decodeIfPresent(String.self, forKey: .startDate) ?? nil)
        
        if when != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            self.startDate = dateFormatter.date(from: when!)!
        } else {
            throw ScheduleError.noStartDate("No Start Date")
        }
        
        when = try (container.decodeIfPresent(String.self, forKey: .endDate) ?? nil)
        if when != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            self.endDate = dateFormatter.date(from: when!)!
        } else {
            throw ScheduleError.noEndDate("No End Date")
        }
        
        if endDate! < startDate! {throw ScheduleError.startDateAfterEndDate("End Date before Start Date")}
        
        
        self.courtMinutes = try (container.decodeIfPresent(Int.self, forKey: .courtMinutes) ?? nil)
        self.playWeeks = try (container.decodeIfPresent([PlayWeek].self, forKey: .playWeeks) ?? nil)
        self.players = try (container.decodeIfPresent([Player].self, forKey: .players) ?? nil)!
        let allDates: [String]? = try container.decodeIfPresent([String].self, forKey: .blockedDays) ?? nil
        self.blockedDays = [Date]()
        if allDates != nil { // convert array of date strings to array of dates using formatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            self.blockedDays = allDates!.compactMap { dateFormatter.date(from: $0) }
        }
        //
        //  Validate PlayWeeks.  If there is nothing in the Playweek, create the array
        //
        if self.playWeeks == nil {
            self.playWeeks = [PlayWeek]()
            var thisWeek: Date = startDate!
            while thisWeek < endDate! {
                self.playWeeks!.append(PlayWeek(date:thisWeek))
                thisWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: thisWeek)!
            }
        }

        
        if  self.players!.count < Constants.minimumNumberOfPlayers {
            throw ScheduleError.startDateAfterEndDate("Need " + String(Constants.minimumNumberOfPlayers) + " players and there are only " + String(self.players!.count))
        }
//  figure out how many weeks each person gets to play this season.  This is a function of how many players there are (e.g. if four players,
//  everyone plays every week.  If 6 players, everyone plays 4 out of 6 weeks.  We also factor in the playing percentage weight.
//  a value of 1.0 means this is a full time player - this affects the player's cost and the nujmber of weeks they get to play.  a .5 means they
//  play half as many weeks as a 1.0 weighted player.  The individual's cost will be calculated based on the total number of weeks each person plays
//
        var totalweight = 0.0
        for p in self.players! {
            totalweight += p.percentPlaying!
        }
        let unweightedWeeksPlying: Double = Double(Constants.minimumNumberOfPlayers * self.playWeeks!.count)
        for p in self.players! {
            let weightedBias:Double = (p.percentPlaying! * unweightedWeeksPlying) / totalweight
            p.numWeeks = Int(weightedBias.rounded())
        }
//
//  Becase of rounding errors, we may need to tweak individual's playing weeks up or down one to align with the actual number
//  of playing slots available.
//

        let playingslots = Constants.minimumNumberOfPlayers * self.playWeeks!.count
        var calculatedSlots = 0
        
        for p in self.players! {
            calculatedSlots += p.numWeeks!
        }
        if playingslots != calculatedSlots {
            print("Actual Slots = \(playingslots) but calculated slots = \(calculatedSlots)")
            var index =  Int.random(in: 0 ..< self.players!.count)
            while calculatedSlots < playingslots {
                let p = self.players![index]
                p.numWeeks! += 1
                calculatedSlots += 1
                index = (index + 1) % self.players!.count
            }
            while calculatedSlots > playingslots {
                let p = self.players![index]
                p.numWeeks! -= 1
                calculatedSlots -= 1
                index = (index + 1) % self.players!.count
            }
        }
        for pw in self.playWeeks! {
            pw.scheduledPlayers = pw.scheduledPlayersNames!.map{ self.FindPlayer(name:$0)! }
        }
    }
//  MARK: Find Slot
//  FindSlot attempts to find a an avaiable week to schedule this player.  We randomly select a week to start and then walk through the PlayWeeks from there.
//  If we find a week that still needs a player, that does not already have this player and the PlayWeek is not in the PLayer's blocked weeks, return.
//
//  If that doesn't work (usually towards the end), then let's find a week that is completely filled and the player is already scheduled to play and swap him ou
//  with another viable week.  Once he's ben swapepd out, we can add him to this week.
//
//  If that fails, give up.
//

    func findSlot(p: Player) ->PlayWeek? {
        var index = Int.random(in: 0 ..< self.playWeeks!.count)
        var maxloop = self.playWeeks!.count
//
//  First, randomly pick a slot and see if there is an opening, that p is not already scheduled in here and that p can
//  be scheduled here (not in p's blockedDays list.  If so, we found our slot.  Else, keep walking through the playweeks
//  and find the first week that matches this criteria.
//
        while maxloop > 0 {
            // Keep trying until we exhaust all slots
            // This slot is good only if: there are less than 4 players assigned, this player is not already assigned,
            // this week is not in the player's blocked weeks
            
            maxloop -= 1
            let pw = self.playWeeks![index]
            if pw.scheduledPlayers!.count < Constants.minimumNumberOfPlayers &&
            pw.isNotScheduled(p: p) &&
            pw.canSchedule(p: p) {
                return pw
            }
            index = (index + 1) % self.playWeeks!.count
        }
//
//  If we get here, there are probably PlayWeeks that have less than min players bt already have this player scheduled.
//  Let's try to swap this player on the short week, with another player from a week that doesn't contain player.
//
        maxloop = self.playWeeks!.count
        var fromIndex:Int = -1
        var sourceWeek: PlayWeek
        
        while(maxloop > 0) {
            maxloop -= 1
            sourceWeek = self.playWeeks![index]
            if sourceWeek.couldSchedule(p: p) {     // see if we could schedule p here if it were not already full.
// we found a slot that has all of the players booked.  now lets see if we can move one of the scheduled players to anoher seek to make room for this
//  player.
                fromIndex = index
                break
            }
            
            index = (index + 1) % self.playWeeks!.count
        }
        
        if fromIndex == -1 {
            print("***Couldn't find another week to swap this player with***")
            return nil
        }
//
//  Now, for each of the players in the source week, try to find another week to move them to in order to create room for Player p.
//
        sourceWeek = self.playWeeks![fromIndex]
        for swapPlayer in sourceWeek.scheduledPlayers! {
            
            maxloop = self.playWeeks!.count-1
            index = (fromIndex + 1) % self.playWeeks!.count
            
            while maxloop > 0 {
                
                let dstWeek = self.playWeeks![index]

                if dstWeek.canSchedule(p: swapPlayer) { // there is room and swapPlayer is not scheduled.
                        sourceWeek.unSchedulePlayer(p: swapPlayer)
                        dstWeek.schedulePlayer(p: swapPlayer)
                        return findSlot(p: p)  // ok, we should have successfully moved a player and created a slot for p.
                    
                }
                maxloop -= 1
                index = (index + 1) % self.playWeeks!.count

            }
        }
        return findSlot(p: p)    // one more time.
    }
    
    func BuildSchedule() {
        
        if isBuilt {return}
        
        for p in self.players! {
            for _ in 0 ..< p.numWeeks! {
                let pw = self.findSlot(p: p)
                pw?.schedulePlayer(p: p)
            }
        }
        
        for _ in 0 ..< Constants.scrambleCount {
            let srcweek = self.playWeeks![Int.random(in: 0 ..< self.playWeeks!.count)]
            let dstweek = self.playWeeks![Int.random(in: 0 ..< self.playWeeks!.count)]
            let srcplayer = self.players![Int.random(in: 0 ..< self.players!.count)]
            let dstplayer = self.players![Int.random(in: 0 ..< self.players!.count)]
            
            if dstweek.isNotScheduled(p: srcplayer) &&
                dstweek.canSchedule(p: srcplayer) &&
                srcweek.isNotScheduled(p: dstplayer) &&
                srcweek.canSchedule(p: dstplayer) {
                
                    srcweek.unSchedulePlayer(p: srcplayer)
                    srcweek.schedulePlayer(p: dstplayer)
                    dstweek.unSchedulePlayer(p: dstplayer)
                    dstweek.schedulePlayer(p: srcplayer)
            }
        }
        
        self.isBuilt = true
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        try container.encode(dateFormatter.string(from: self.startDate!), forKey: .startDate)
        try container.encode(dateFormatter.string(from: self.endDate!), forKey: .endDate)
        try container.encode(courtMinutes, forKey: .courtMinutes)
        try container.encode(playWeeks, forKey: .playWeeks)
        try container.encode(players, forKey: .players)
        if blockedDays != nil && blockedDays!.count > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            let addDateStr = self.blockedDays!.map{ dateFormatter.string(from: $0) }
            try container.encode(addDateStr, forKey: .blockedDays)
        }
    }
    
}

