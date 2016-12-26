cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100014 batch6 >> ~/SWIM/scriptsTest/workGenLogs/batch-14.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-14.txt  &  batch14=$!  
wait $batch14 
