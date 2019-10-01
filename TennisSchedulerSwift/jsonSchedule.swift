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
	  "email": "unknown",
	  "phone": "unknown",
      "blockedDays": [ "10/25/18", "01/17/19", "01/24/19", "02/21/19", "03/28/19" ]
    },

    {
      "name": "Waco Kid",
      "percentPlaying": 0.5,
      "blockedDays": [  "10/25/18","02/21/19", "03/28/19" ]
    },
    {
      "name": "Bart",
      "percentPlaying": 0.25,
      "blockedDays": [ "10/25/18","01/17/19", "01/24/19" ]
    },

    {
      "name": "Mongo",
      "percentPlaying": 1.0,
      "blockedDays": [ "10/25/18", "04/04/19", "04/18/19" ]
   },

     {
      "name": "Howard Johnson",
      "percentPlaying": 0.33,
		"blockedDays": [ "01/17/19", "01/24/19" ]
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



    "startDate": "09/13/18",
	"endDate":  "05/02/19",
    "courtMinutes" :  90,
    "blockedDays": [ "12/27/18" ]
 
}
""".data(using: .utf8)!
/*

 "MemberDues" : 120.00,
 "MemberDuesNeeded":  4,
 "HourlyCourtCost" :  80.00
 
 */
