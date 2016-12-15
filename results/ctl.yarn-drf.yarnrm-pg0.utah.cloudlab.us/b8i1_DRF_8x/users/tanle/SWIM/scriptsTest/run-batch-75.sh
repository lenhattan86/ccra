cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100075 batch3 >> ~/SWIM/scriptsTest/workGenLogs/batch-75.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-75.txt  &  batch75=$!  
wait $batch75 
