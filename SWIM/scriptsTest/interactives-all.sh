#!/bin/bash
mkdir ~/SWIM/scriptsTest/workGenLogs
./run-interactive-0.sh &
sleep 500
./run-interactive-1.sh &
lastInteractive=$! ; 
 wait $lastInteractive 500
