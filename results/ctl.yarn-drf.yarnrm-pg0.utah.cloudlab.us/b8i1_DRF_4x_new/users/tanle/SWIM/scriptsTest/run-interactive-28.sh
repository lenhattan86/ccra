cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  28 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-28_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-28_0.txt  &  interactive28="$interactive28 $!"  
wait $interactive28 
