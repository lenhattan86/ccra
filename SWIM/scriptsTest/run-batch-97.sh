cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100097 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-97.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-97.txt  &  batch97=$!  
wait $batch97 
