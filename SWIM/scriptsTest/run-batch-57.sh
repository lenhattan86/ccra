cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100057 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-57.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-57.txt  &  batch57=$!  
wait $batch57 
