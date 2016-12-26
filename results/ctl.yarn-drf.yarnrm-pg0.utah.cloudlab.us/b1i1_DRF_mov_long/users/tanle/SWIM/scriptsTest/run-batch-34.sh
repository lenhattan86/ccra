cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100034 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-34.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-34.txt  &  batch34=$!  
wait $batch34 
