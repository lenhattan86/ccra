cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100028 batch4 >> ~/SWIM/scriptsTest/workGenLogs/batch-28.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-28.txt  &  batch28=$!  
wait $batch28 
