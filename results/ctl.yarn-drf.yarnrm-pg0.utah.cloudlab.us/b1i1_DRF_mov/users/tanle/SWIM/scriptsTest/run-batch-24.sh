cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100024 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-24.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-24.txt  &  batch24=$!  
wait $batch24 
