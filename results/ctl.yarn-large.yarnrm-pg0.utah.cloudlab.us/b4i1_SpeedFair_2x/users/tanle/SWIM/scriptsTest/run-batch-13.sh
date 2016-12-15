cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100013 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-13.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-13.txt  &  batch13=$!  
wait $batch13 
