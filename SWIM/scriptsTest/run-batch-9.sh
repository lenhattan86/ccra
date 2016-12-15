cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100009 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-9.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-9.txt  &  batch9=$!  
wait $batch9 
