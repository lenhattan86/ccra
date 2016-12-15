cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  17 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-17_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-17_0.txt  &  interactive17="$interactive17 $!"  
wait $interactive17 
