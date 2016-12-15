cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100078 batch6 >> ~/SWIM/scriptsTest/workGenLogs/batch-78.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-78.txt  &  batch78=$!  
wait $batch78 
