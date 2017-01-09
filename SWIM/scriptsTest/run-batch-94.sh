cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100094 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-94.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-94.txt  &  batch94=$!  
wait $batch94 
