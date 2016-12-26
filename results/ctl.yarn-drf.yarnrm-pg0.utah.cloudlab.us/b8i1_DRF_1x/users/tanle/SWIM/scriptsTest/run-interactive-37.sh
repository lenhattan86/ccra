cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  37 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-37_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-37_0.txt  &  interactive37="$interactive37 $!"  
wait $interactive37 
