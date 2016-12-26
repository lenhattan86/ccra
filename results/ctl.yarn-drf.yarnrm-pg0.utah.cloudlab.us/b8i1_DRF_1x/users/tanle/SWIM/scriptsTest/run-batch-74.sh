cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100074 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-74.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-74.txt  &  batch74=$!  
wait $batch74 
