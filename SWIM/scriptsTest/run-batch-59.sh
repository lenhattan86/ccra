cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100059 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-59.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-59.txt  &  batch59=$!  
wait $batch59 
