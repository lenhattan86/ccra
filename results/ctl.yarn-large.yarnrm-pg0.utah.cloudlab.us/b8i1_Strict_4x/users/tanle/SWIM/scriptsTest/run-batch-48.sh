cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100048 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-48.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-48.txt  &  batch48=$!  
wait $batch48 
