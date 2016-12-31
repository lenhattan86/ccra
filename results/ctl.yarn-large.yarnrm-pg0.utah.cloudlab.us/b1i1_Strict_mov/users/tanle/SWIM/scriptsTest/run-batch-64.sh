cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100064 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-64.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-64.txt  &  batch64=$!  
wait $batch64 
