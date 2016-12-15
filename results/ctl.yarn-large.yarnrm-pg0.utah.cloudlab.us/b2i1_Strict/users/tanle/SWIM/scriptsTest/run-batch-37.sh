cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100037 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-37.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-37.txt  &  batch37=$!  
wait $batch37 
