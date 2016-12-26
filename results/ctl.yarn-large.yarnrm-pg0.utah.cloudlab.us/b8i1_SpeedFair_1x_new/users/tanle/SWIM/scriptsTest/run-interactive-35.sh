cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  35 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-35_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-35_0.txt  &  interactive35="$interactive35 $!"  
wait $interactive35 
