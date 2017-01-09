cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100093 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-93.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-93.txt  &  batch93=$!  
wait $batch93 
