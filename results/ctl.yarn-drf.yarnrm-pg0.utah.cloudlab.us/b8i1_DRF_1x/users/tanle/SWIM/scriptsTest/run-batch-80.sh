cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100080 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-80.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-80.txt  &  batch80=$!  
wait $batch80 
