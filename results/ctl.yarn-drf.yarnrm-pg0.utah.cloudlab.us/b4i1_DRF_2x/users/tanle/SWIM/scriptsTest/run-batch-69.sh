cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100069 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-69.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-69.txt  &  batch69=$!  
wait $batch69 
