cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100082 batch2 >> ~/SWIM/scriptsTest/workGenLogs/batch-82.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-82.txt  &  batch82=$!  
wait $batch82 
