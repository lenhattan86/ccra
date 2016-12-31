cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100046 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-46.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-46.txt  &  batch46=$!  
wait $batch46 
