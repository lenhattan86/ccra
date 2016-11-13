#!/bin/bash
mkdir workGenLogs
./run-batch-0.sh &
sleep 49
serverList="nm ctl  cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27 cp-29 cp-30 cp-31 cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40 cp-41 cp-42" 
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
serverList="nm ctl  cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27 cp-29 cp-30 cp-31 cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40 cp-41 cp-42" 
for server in $serverList; do  
    ssh $server "sudo rm -rf /dev/yarn-logs/* " & 
done 
 
./run-batch-11.sh &
sleep 112
./run-batch-12.sh &
sleep 57
./run-batch-13.sh &
sleep 32
./run-batch-14.sh &
sleep 26
./run-batch-15.sh &
sleep 206
./run-batch-16.sh &
sleep 182
./run-batch-17.sh &
sleep 16
./run-batch-18.sh &
sleep 52
./run-batch-19.sh &
sleep 5
./run-batch-20.sh &
sleep 2
serverList="nm ctl  cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27 cp-29 cp-30 cp-31 cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40 cp-41 cp-42" 
for server in $serverList; do  
    ssh $server "sudo rm -rf /dev/yarn-logs/* " & 
done 
 
./run-batch-21.sh &
sleep 27
./run-batch-22.sh &
sleep 20
./run-batch-23.sh &
sleep 28
./run-batch-24.sh &
sleep 23
./run-batch-25.sh &
sleep 135
./run-batch-26.sh &
sleep 33
./run-batch-27.sh &
sleep 43
./run-batch-28.sh &
sleep 29
./run-batch-29.sh &
sleep 140
./run-batch-30.sh &
sleep 4
serverList="nm ctl  cp-1 cp-2 cp-3 cp-4 cp-5 cp-6 cp-7 cp-8 cp-9 cp-10 cp-11 cp-12 cp-13 cp-15 cp-16 cp-17 cp-18 cp-19 cp-20 cp-21 cp-22 cp-23 cp-24 cp-25 cp-26 cp-27 cp-29 cp-30 cp-31 cp-33 cp-34 cp-35 cp-36 cp-37 cp-38 cp-39 cp-40 cp-41 cp-42" 
for server in $serverList; do  
    ssh $server "sudo rm -rf /dev/yarn-logs/* " & 
done 
 
./run-batch-31.sh &
sleep 31
./run-batch-32.sh &
sleep 25
./run-batch-33.sh &
sleep 21
./run-batch-34.sh &
sleep 110
./run-batch-35.sh &
sleep 118
./run-batch-36.sh &
sleep 1
./run-batch-37.sh &
sleep 0
./run-batch-38.sh &
sleep 1
./run-batch-39.sh &
sleep 1
# max input 684986073
# inputPartitionSize 57303500
# inputPartitionCount 40
