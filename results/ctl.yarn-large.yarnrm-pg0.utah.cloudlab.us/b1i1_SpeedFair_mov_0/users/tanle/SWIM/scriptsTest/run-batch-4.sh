cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100004 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-4.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-4.txt  &  batch4=$!  
wait $batch4 
