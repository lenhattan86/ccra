cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100021 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-21.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-21.txt  &  batch21=$!  
wait $batch21 
