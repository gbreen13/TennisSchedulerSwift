//
//  playWeek.swift
//  TennisSchedulerSwift
//
//  Created by George Breen on 9/19/19.
//  Copyright © 2019 George Breen. All rights reserved.
//


import Foundation

class PlayWeek: CustomStringConvertible, Codable {
    
    enum CodingKeys: CodingKey {
        case date, scheduledPlayers
    }
    enum PlayWeekError: Error {
        case invalidDate
    }
    var scheduledPlayersNames: [String]?  // who's playing this week
	var scheduledPlayers: [Player]?			// the player class that matches the names.
    var date: Date
    
    init(date: Date) {
        self.date = date
        self.scheduledPlayers = [Player]()
		self.scheduledPlayersNames = [String]()
    }
    
    func schedulePlayer(p: Player) {
        if self.scheduledPlayers!.contains(p) {
            return// already there
        }
        self.scheduledPlayers!.append(p)
        p.scheduledWeeks += 1
        
    }
	
	func unSchedulePlayer(p: Player) {
		if let index = self.scheduledPlayers!.firstIndex(of: p) {
			self.scheduledPlayers!.remove(at: index)
			p.scheduledWeeks -= 1
		}
		
	}
	
	func isScheduled(p: Player) ->Bool {
		return(self.scheduledPlayers!.contains(p))
	}
	
	func isNotScheduled(p: Player) ->Bool {
		return(self.isScheduled(p: p) == false)
	}
	
	func canSchedule(p: Player) ->Bool {
		if self.scheduledPlayers!.count >= Constants.minimumNumberOfPlayers { return false}
		return (self.isNotScheduled(p: p) && (p.blockedDays!.contains(self.date) == false))
	}
	
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        var s: String = dateFormatter.string(from: self.date) + "\t"
        s += "(\(scheduledPlayers!.count))"
        if(scheduledPlayers != nil && scheduledPlayers!.count > 0){
			for sp in scheduledPlayers! { s = s + "\(sp.name!), "}
        } else {
            s += "no players scheduled"
        }
        s += "\n"
        return s
    }
	

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.scheduledPlayersNames = try (container.decodeIfPresent([String].self, forKey: .scheduledPlayers) ?? nil)!
        let when: String? = try (container.decodeIfPresent(String.self, forKey: .date) ?? nil)
        if when != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            self.date = dateFormatter.date(from: when!)!
        } else {
            throw PlayWeekError.invalidDate
        }
        if self.scheduledPlayersNames == nil { self.scheduledPlayersNames = [String]()}
		self.scheduledPlayers = [Player]()	// create empty array.  after the schedule has been completely read in, we will go back
											// and cfill this in the with Player class that matches the name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        try container.encode(dateFormatter.string(from: self.date), forKey: .date)
		let scheduledPlayersNames = self.scheduledPlayers!.map{ $0.name }
		try container.encode(scheduledPlayersNames, forKey: .scheduledPlayers)
    }
	
}
