cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  46 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-46_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-46_0.txt  &  interactive46="$interactive46 $!"  
wait $interactive46 
