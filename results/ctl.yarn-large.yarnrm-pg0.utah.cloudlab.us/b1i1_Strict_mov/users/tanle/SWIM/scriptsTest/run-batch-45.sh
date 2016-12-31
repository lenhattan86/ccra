cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100045 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-45.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-45.txt  &  batch45=$!  
wait $batch45 
