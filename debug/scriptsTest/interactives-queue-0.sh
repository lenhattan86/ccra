#!/bin/bash
mkdir ~/SWIM/scriptsTest/workGenLogs
./run-interactive-0_0.sh &
 
./run-interactive-1_0.sh &
 
./run-interactive-2_0.sh &
 
./run-interactive-3_0.sh &
lastInteractive=$! ; 
 wait $lastInteractive 0
