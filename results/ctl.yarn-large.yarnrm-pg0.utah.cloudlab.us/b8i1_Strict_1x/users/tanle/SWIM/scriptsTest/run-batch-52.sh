cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100052 batch4 >> ~/SWIM/scriptsTest/workGenLogs/batch-52.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-52.txt  &  batch52=$!  
wait $batch52 
