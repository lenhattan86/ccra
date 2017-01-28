cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100099 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-99.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-99.txt  &  batch99=$!  
wait $batch99 
