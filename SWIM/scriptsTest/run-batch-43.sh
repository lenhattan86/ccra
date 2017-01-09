cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100043 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-43.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-43.txt  &  batch43=$!  
wait $batch43 
