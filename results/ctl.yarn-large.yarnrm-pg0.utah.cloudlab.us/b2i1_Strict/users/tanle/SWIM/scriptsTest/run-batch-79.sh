cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  100079 batch1 >> ~/SWIM/scriptsTest/workGenLogs/batch-79.txt 2>> ~/SWIM/scriptsTest/workGenLogs/batch-79.txt  &  batch79=$!  
wait $batch79 
