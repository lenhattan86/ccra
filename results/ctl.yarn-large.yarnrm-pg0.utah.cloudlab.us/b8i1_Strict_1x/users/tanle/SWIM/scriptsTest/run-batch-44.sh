cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100044 batch4 >> ~/SWIM/scriptsTest/workGenLogs/batch-44.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-44.txt  &  batch44=$!  
wait $batch44 
