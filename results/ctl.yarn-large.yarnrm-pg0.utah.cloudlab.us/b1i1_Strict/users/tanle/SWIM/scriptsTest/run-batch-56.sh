cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100056 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-56.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-56.txt  &  batch56=$!  
wait $batch56 
