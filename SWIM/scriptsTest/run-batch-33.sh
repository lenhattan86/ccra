cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100033 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-33.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-33.txt  &  batch33=$!  
wait $batch33 
