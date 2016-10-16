#!/bin/bash
mkdir workGenLogs
./run-interactive-0.sh &
sleep 240
./run-interactive-1.sh &
# max input 382023
# inputPartitionSize 57303500
# inputPartitionCount 40
