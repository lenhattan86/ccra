cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100068 batch0 >> ~/SWIM/scriptsTest/workGenLogs/batch-68.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-68.txt  &  batch68=$!  
wait $batch68 
