cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100065 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-65.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-65.txt  &  batch65=$!  
wait $batch65 
