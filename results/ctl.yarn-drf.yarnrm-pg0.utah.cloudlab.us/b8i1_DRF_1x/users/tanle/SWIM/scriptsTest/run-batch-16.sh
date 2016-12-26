cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100016 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-16.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-16.txt  &  batch16=$!  
wait $batch16 
