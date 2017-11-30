#!/bin/bash
mkdir ~/SWIM/scriptsTest/workGenLogs
./run-batch-0.sh &
./run-batch-1.sh &
./run-batch-2.sh &
./run-batch-3.sh &
./run-batch-4.sh &

 wait