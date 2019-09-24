//
//  jsonSchedule.swift
//  TennisSchedulerSwift
//
//  Created by George Breen on 9/19/19.
//  Copyright © 2019 George Breen. All rights reserved.
//


let jsonSchedule = """
{
  "players": [
    {
      "name": "Hedley LaMar",
      "percentPlaying": 1.0,
      "blockedDays": [ "10/25/18", "1/17/19", "1/24/19", "2/21/19", "3/28/19" ]
    },

    {
      "name": "Waco Kid",
      "percentPlaying": 0.5,
      "blockedDays": [  "2/21/19", "3/28/19" ]
    },
    {
      "name": "Bart",
      "percentPlaying": 0.25,
      "blockedDays": [ "1/17/19", "1/24/19" ]
    },

    {
      "name": "Mongo",
      "percentPlaying": 1.0,
      "blockedDays": [ "4/04/19", "4/18/19" ]
   },

     {
      "name": "Howard Johnson",
      "percentPlaying": 0.33
    },


    {
      "name": "Lilli Von Shtupp",
      "percentPlaying": 1.0
    },
    {
      "name": "Gabby",
      "percentPlaying": 0.75
    },

    {
      "name": "The Gov",
      "percentPlaying": 1.0
    }


  ],



    "startDate": "9/13/18",
	"endDate":  "5/2/19",
    "courtMinutes" :  90,
    "blockedDays": [ "12/27/18" ]
 
}
""".data(using: .utf8)!
/*
"playWeeks" : [
 {
 "date": "01/23/45",
 "scheduledPlayers": ["Bob", "Mike", "June"]
 }
 ],
 "MemberDues" : 120.00,
 "MemberDuesNeeded":  4,
 "HourlyCourtCost" :  80.00
 
 */
