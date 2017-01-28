cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100083 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-83.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-83.txt  &  batch83=$!  
wait $batch83 
