cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100073 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-73.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-73.txt  &  batch73=$!  
wait $batch73 
