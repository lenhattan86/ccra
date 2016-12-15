cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100049 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-49.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-49.txt  &  batch49=$!  
wait $batch49 
