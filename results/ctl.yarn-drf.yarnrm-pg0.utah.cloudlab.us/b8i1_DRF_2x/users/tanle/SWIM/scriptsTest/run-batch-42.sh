cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100042 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-42.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-42.txt  &  batch42=$!  
wait $batch42 
