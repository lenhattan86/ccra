cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100098 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-98.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-98.txt  &  batch98=$!  
wait $batch98 
