#!/bin/bash
mkdir workGenLogs
./run-batch-0.sh &
sleep 49
serverList="nm ctl  cp-1 cp-2 cp-3" 
for server in $serverList; do  
    ssh $server "sudo rm -rf /dev/yarn-logs/* " & 
done 
 
./run-batch-1.sh &
sleep 52
./run-batch-2.sh &
sleep 21
./run-batch-3.sh &
sleep 75
./run-batch-4.sh &
sleep 11
./run-batch-5.sh &
sleep 141
./run-batch-6.sh &
sleep 24
./run-batch-7.sh &
sleep 6
./run-batch-8.sh &
sleep 84
./run-batch-9.sh &
sleep 24
./run-batch-10.sh &
sleep 10
serverList="nm ctl  cp-1 cp-2 cp-3" 
for server in $serverList; do  
    ssh $server "sudo rm -rf /dev/yarn-logs/* " & 
done 
 
./run-batch-11.sh &
sleep 112
# max input 24155
# inputPartitionSize 57303500
# inputPartitionCount 40
