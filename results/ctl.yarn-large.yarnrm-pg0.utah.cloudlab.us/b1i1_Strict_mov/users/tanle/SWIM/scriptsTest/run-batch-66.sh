cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100066 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-66.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-66.txt  &  batch66=$!  
wait $batch66 