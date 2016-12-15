cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100070 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-70.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-70.txt  &  batch70=$!  
wait $batch70 
