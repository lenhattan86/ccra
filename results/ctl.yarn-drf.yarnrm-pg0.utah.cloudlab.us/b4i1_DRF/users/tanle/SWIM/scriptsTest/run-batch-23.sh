cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100023 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-23.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-23.txt  &  batch23=$!  
wait $batch23 
