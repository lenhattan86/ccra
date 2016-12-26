cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100088 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-88.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-88.txt  &  batch88=$!  
wait $batch88 
