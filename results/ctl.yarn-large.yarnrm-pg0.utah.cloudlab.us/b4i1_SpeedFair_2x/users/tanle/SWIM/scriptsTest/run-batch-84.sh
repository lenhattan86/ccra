cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100084 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-84.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-84.txt  &  batch84=$!  
wait $batch84 
