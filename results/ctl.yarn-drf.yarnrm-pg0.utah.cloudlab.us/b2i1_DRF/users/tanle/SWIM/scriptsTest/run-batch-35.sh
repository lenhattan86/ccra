cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100035 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-35.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-35.txt  &  batch35=$!  
wait $batch35 
