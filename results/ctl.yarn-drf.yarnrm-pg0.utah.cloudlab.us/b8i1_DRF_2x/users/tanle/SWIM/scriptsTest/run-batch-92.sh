cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100092 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-92.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-92.txt  &  batch92=$!  
wait $batch92 
