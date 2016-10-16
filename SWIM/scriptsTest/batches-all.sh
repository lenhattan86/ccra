#!/bin/bash
mkdir workGenLogs
./run-batch-0.sh &
sleep 49
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
# max input 24155
# inputPartitionSize 57303500
# inputPartitionCount 40
