//
//  playWeek.swift
//  TennisSchedulerSwift
//
//  Created by George Breen on 9/19/19.
//  Copyright © 2019 George Breen. All rights reserved.
//


import Foundation

struct PlayWeek: CustomStringConvertible, Codable {
    
    enum CodingKeys: CodingKey {
        case date, scheduledPlayers
    }
    enum PlayWeekError: Error {
        case invalidDate
    }
    var scheduledPlayers: [String]?  // who's playing this week
    var date: Date
    
    init(date: Date) {
        self.date = date
        self.scheduledPlayers = [String]()
    }
    
    mutating func schedulePlayer(p: Player) {
        if self.scheduledPlayers!.contains(p.name!) {
            return// already there
        }
        self.scheduledPlayers!.append(p.name!)
        p.scheduledWeeks += 1
        
    }
    
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        var s: String = dateFormatter.string(from: self.date) + "\t"
        
        if(scheduledPlayers != nil && scheduledPlayers!.count > 0){
            s += String(describing: self.scheduledPlayers)
        } else {
            s += "no players scheduled"
        }
        s += "\n"
        return s
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.scheduledPlayers = try (container.decodeIfPresent([String].self, forKey: .scheduledPlayers) ?? nil)!
        let when: String? = try (container.decodeIfPresent(String.self, forKey: .date) ?? nil)
        if when != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            self.date = dateFormatter.date(from: when!)!
        } else {
            throw PlayWeekError.invalidDate
        }
        if self.scheduledPlayers == nil { self.scheduledPlayers = [String]()}
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        try container.encode(dateFormatter.string(from: self.date), forKey: .date)
        try container.encode(scheduledPlayers, forKey: .scheduledPlayers)
    }
    
    mutating func unSchedulePlayer(p: Player) {
        var index: Int?
        index = self.scheduledPlayers!.firstIndex(of: p.name!)
        if index != nil {
            self.scheduledPlayers!.append(p.name!)
            p.scheduledWeeks -= 1
        }
    }
    
}
