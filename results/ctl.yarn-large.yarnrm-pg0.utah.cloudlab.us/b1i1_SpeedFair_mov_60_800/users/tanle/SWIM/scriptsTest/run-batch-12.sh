cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100012 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-12.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-12.txt  &  batch12=$!  
wait $batch12 
