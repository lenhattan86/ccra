cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100076 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-76.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-76.txt  &  batch76=$!  
wait $batch76 
