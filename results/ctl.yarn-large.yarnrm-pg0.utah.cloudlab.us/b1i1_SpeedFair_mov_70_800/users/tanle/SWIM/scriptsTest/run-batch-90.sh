cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100090 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-90.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-90.txt  &  batch90=$!  
wait $batch90 
