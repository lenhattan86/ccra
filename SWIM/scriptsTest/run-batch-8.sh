cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100008 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-8.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-8.txt  &  batch8=$!  
wait $batch8 
