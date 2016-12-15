cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100058 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-58.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-58.txt  &  batch58=$!  
wait $batch58 
