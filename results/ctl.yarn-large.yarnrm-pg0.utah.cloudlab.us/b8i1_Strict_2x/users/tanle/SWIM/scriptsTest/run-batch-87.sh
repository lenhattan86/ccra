cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100087 batch7 >> ~/SWIM/scriptsTest/workGenLogs/batch-87.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-87.txt  &  batch87=$!  
wait $batch87 
