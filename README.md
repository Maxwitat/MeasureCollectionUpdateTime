# MeasureCollectionUpdateTime
PerfTest: Measure the time it takes to create a collection, add a machine and delete the collection again

Anybody who worked with ConfigMgr for longer knows that slow collection updates can be a real nuisance. You add a machine to a collection and sometimes it takes ages until it appears. You can’t even say exactly when it showed up since the hourglass doesn’t disappear until you update the display. So how long did it really take? To be able to measure the time, I wrote a script that creates a collection, adds a machine to it and then checks every 2 seconds if it is already there. Once it is, it deletes the collection again and displays the time.

To identify performance bottlenecks you may need to run this script to different times, under different accounts (RBAC can influence the performance) and from different locations. 
