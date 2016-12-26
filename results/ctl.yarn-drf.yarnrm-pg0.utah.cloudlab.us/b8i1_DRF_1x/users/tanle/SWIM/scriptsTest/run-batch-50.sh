cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100050 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-50.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-50.txt  &  batch50=$!  
wait $batch50 
