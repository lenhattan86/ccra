cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100000 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-0.txt  &  batch0=$!  
wait $batch0 
