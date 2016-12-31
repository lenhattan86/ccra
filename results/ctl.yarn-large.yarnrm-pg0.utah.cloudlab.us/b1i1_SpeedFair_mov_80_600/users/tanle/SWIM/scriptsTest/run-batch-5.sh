cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100005 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-5.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-5.txt  &  batch5=$!  
wait $batch5 
