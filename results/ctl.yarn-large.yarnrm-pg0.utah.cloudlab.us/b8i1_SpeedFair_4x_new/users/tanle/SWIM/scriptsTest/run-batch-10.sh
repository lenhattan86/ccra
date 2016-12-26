cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100010 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-10.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-10.txt  &  batch10=$!  
wait $batch10 
