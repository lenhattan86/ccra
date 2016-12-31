cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  1 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-1_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-1_0.txt  &  interactive1="$interactive1 $!"  
wait $interactive1 
