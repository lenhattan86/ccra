cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100061 batch5 >> ~/SWIM/scriptsTest/workGenLogs/batch-61.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-61.txt  &  batch61=$!  
wait $batch61 
