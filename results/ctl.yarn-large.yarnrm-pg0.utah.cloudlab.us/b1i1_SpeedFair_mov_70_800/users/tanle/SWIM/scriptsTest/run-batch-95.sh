cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100095 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-95.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-95.txt  &  batch95=$!  
wait $batch95 
