cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100038 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-38.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-38.txt  &  batch38=$!  
wait $batch38 
