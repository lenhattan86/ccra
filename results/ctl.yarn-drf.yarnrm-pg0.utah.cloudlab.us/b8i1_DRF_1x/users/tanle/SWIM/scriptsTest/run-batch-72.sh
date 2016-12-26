cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100072 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-72.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-72.txt  &  batch72=$!  
wait $batch72 
