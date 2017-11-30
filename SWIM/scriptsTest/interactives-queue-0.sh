#!/bin/bash
mkdir ~/SWIM/scriptsTest/workGenLogs
sleep 30
./run-interactive-0_0.sh &
lastInteractive=$! ; 
 wait $lastInteractive 600
