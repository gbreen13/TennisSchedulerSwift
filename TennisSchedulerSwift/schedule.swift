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
        case noStartDate
        case noEndDate
        case startDateAfterEndDate
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var when: String? = try (container.decodeIfPresent(String.self, forKey: .startDate) ?? nil)
        
        if when != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            self.startDate = dateFormatter.date(from: when!)!
        } else {
            throw ScheduleError.noStartDate
        }
        
        when = try (container.decodeIfPresent(String.self, forKey: .endDate) ?? nil)
        if when != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            self.endDate = dateFormatter.date(from: when!)!
        } else {
            throw ScheduleError.noEndDate
        }
        
        if endDate! < startDate! {throw ScheduleError.startDateAfterEndDate}
        
        
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
            print("creating playweek list")
            self.playWeeks = [PlayWeek]()
            var thisWeek: Date = startDate!
            while thisWeek < endDate! {
                self.playWeeks!.append(PlayWeek(date:thisWeek))
                thisWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: thisWeek)!
            }
            print("done creating playweek list")
        }
        
        
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

