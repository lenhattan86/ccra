cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100031 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-31.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-31.txt  &  batch31=$!  
wait $batch31 
