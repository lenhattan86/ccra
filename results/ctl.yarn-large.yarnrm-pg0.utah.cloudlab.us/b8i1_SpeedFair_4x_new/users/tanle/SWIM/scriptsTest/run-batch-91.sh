cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100091 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-91.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-91.txt  &  batch91=$!  
wait $batch91 
