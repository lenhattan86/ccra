cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100026 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-26.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-26.txt  &  batch26=$!  
wait $batch26 
