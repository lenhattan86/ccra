cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100077 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-77.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-77.txt  &  batch77=$!  
wait $batch77 
