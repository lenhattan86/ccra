cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100017 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-17.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-17.txt  &  batch17=$!  
wait $batch17 
