cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100002 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-2.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-2.txt  &  batch2=$!  
wait $batch2 
