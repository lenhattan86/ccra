cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100006 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-6.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-6.txt  &  batch6=$!  
wait $batch6 
