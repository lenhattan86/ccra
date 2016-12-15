cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100086 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-86.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-86.txt  &  batch86=$!  
wait $batch86 
