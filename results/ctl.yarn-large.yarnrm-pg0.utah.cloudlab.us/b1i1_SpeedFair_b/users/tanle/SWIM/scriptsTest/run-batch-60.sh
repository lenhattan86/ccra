cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100060 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-60.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-60.txt  &  batch60=$!  
wait $batch60 
