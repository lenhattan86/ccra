cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100051 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-51.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-51.txt  &  batch51=$!  
wait $batch51 
