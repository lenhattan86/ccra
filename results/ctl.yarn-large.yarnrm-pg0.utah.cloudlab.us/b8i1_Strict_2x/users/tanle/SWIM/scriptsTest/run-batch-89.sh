cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100089 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-89.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-89.txt  &  batch89=$!  
wait $batch89 
