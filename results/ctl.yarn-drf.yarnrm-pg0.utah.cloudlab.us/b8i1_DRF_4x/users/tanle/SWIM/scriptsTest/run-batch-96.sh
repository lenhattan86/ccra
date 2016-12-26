cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100096 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-96.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-96.txt  &  batch96=$!  
wait $batch96 
