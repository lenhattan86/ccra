cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  2 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-2_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-2_0.txt  &  interactive2="$interactive2 $!"  
wait $interactive2 
