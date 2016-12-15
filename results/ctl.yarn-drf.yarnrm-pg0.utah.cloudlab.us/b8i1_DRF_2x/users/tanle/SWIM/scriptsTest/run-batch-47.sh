cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100047 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-47.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-47.txt  &  batch47=$!  
wait $batch47 
