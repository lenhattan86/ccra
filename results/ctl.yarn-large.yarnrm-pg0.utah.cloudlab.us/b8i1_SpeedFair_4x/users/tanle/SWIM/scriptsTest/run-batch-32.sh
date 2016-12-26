cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100032 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-32.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-32.txt  &  batch32=$!  
wait $batch32 
