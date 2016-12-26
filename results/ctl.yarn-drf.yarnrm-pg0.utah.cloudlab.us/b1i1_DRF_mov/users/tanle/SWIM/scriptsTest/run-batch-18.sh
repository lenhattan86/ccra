cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100018 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-18.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-18.txt  &  batch18=$!  
wait $batch18 
