cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100019 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-19.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-19.txt  &  batch19=$!  
wait $batch19 
