cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100062 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-62.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-62.txt  &  batch62=$!  
wait $batch62 
