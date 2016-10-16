#!/bin/bash
mkdir workGenLogs
./run-interactive-0.sh &
sleep 120
./run-interactive-1.sh &
sleep 120
./run-interactive-2.sh &
sleep 120
./run-interactive-3.sh &
sleep 120
./run-interactive-4.sh &
# max input 382023
# inputPartitionSize 57303500
# inputPartitionCount 40
