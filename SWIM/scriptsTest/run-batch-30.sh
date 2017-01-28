cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100030 batch6 >> ~/SWIM/scriptsTest/workGenLogs/batch-30.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-30.txt  &  batch30=$!  
wait $batch30 
