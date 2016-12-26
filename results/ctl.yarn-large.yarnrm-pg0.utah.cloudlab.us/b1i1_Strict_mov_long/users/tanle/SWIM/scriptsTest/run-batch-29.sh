cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100029 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-29.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-29.txt  &  batch29=$!  
wait $batch29 
