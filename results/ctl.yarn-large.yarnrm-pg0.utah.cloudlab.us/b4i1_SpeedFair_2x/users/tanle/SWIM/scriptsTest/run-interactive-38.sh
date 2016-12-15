cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  38 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-38_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-38_0.txt  &  interactive38="$interactive38 $!"  
wait $interactive38 
