cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100041 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-41.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-41.txt  &  batch41=$!  
wait $batch41 
