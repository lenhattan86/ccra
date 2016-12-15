cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100085 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-85.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-85.txt  &  batch85=$!  
wait $batch85 
