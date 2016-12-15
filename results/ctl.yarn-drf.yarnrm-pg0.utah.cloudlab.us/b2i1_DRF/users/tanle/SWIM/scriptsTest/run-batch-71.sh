cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100071 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-71.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-71.txt  &  batch71=$!  
wait $batch71 
