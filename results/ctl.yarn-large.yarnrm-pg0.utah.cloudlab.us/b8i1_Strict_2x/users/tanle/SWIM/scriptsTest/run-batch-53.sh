cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100053 batch5 >> ~/SWIM/scriptsTest/workGenLogs/batch-53.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-53.txt  &  batch53=$!  
wait $batch53 
