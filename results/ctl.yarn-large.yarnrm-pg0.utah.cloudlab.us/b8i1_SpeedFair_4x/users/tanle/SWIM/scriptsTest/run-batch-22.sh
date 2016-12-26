cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100022 batch6 >> ~/SWIM/scriptsTest/workGenLogs/batch-22.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-22.txt  &  batch22=$!  
wait $batch22 
