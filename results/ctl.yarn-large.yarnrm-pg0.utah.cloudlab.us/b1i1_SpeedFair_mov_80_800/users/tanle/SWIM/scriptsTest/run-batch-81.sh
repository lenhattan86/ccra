cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100081 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-81.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-81.txt  &  batch81=$!  
wait $batch81 
