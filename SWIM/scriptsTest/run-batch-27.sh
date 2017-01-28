cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100027 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-27.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-27.txt  &  batch27=$!  
wait $batch27 
