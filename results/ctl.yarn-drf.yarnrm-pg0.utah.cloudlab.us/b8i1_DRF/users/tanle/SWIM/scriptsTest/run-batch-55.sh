cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100055 batch7 >> ~/SWIM/scriptsTest/workGenLogs/batch-55.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-55.txt  &  batch55=$!  
wait $batch55 
