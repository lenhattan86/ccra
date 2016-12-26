cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100011 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-11.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-11.txt  &  batch11=$!  
wait $batch11 
