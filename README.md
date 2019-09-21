# TennisSchedulerSwift
This program is a console app for generating a tennis schedule for contract tennis time.

The goal:
- create a tennis schedule for contract tennis time that adheres to certain rules (below) and calculates what everyone
should pay

The setup:
- Contract tennis time is typically weekly and for doubles players
- the group that participates has more than four people so that we can have substitutes and not have to play every week
- some members may choose to play less than others (e.g. 50% participant)
- there may be some locked
- some members have blocked weeks that they simply cannot play.
- we want to make sure that the players are evenly scrambled so the mix is not repetitive.

The players and other key scheduling criteria is defined in jsonSchedule as a JSON record.

There may be some unreconcilable situations where we can't book 4 players for a particular week after multiple attempts to rework the schedule
These weeks are flagged in the final output and a non-member substitute will need to be brought in for that week.

