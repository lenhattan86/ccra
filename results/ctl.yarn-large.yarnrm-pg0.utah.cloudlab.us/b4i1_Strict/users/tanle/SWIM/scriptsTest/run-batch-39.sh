cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100039 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-39.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-39.txt  &  batch39=$!  
wait $batch39 
