//
//  main.swift
//  TennisSchedulerSwift
//
//  Created by George Breen on 9/19/19.
//  Copyright © 2019 George Breen. All rights reserved.
//

import Foundation

do {
    let decoder = JSONDecoder()
    var schedule: Schedule = try decoder.decode(Schedule.self, from: jsonSchedule)
    print(schedule);
    print("###")
    schedule.BuildSchedule()
    print(schedule);
    print("###")
    let jsonEncoder = JSONEncoder()
    var jsonData = Data()
    jsonData = try jsonEncoder.encode(schedule)  // now reencode the data
    let jsonString = String(data: jsonData, encoding: .utf8)!
    print(jsonString)
    schedule = try decoder.decode(Schedule.self, from: jsonString.data(using: .utf8)!)
    print(schedule);
    print("###")
    
} catch {
    if error is Schedule.ScheduleError {
        print(error)
        exit(SIGABRT)
    }
    else {
        print(error.localizedDescription)
    }
}
