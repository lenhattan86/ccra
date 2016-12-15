cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  16 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-16_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-16_0.txt  &  interactive16="$interactive16 $!"  
wait $interactive16 
