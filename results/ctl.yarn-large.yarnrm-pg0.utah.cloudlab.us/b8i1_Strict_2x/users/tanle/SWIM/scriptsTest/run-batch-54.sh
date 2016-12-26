cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100054 batch6 >> ~/SWIM/scriptsTest/workGenLogs/batch-54.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-54.txt  &  batch54=$!  
wait $batch54 
