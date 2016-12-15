cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  14 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-14_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-14_0.txt  &  interactive14="$interactive14 $!"  
wait $interactive14 
