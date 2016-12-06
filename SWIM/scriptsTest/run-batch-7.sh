cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100007 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-7.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-7.txt  &  batch7=$!  
wait $batch7 
