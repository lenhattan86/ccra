cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100036 batch4 >> ~/SWIM/scriptsTest/workGenLogs/batch-36.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-36.txt  &  batch36=$!  
wait $batch36 
