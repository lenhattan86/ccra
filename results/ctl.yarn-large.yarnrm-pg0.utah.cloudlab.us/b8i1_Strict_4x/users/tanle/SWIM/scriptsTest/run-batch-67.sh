cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100067 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-67.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-67.txt  &  batch67=$!  
wait $batch67 
