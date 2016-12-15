cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100063 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-63.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-63.txt  &  batch63=$!  
wait $batch63 
