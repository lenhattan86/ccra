cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100003 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-3.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-3.txt  &  batch3=$!  
wait $batch3 
