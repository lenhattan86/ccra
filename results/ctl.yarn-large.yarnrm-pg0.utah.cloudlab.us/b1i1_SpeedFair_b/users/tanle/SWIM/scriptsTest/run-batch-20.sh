cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100020 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-20.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-20.txt  &  batch20=$!  
wait $batch20 
