cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100040 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-40.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-40.txt  &  batch40=$!  
wait $batch40 
