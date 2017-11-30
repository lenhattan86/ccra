cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100001 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-1.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-1.txt  &  batch1=$!  
wait $batch1 
