cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  47 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-47_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-47_0.txt  &  interactive47="$interactive47 $!"  
wait $interactive47 
