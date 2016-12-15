cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  43 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-43_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-43_0.txt  &  interactive43="$interactive43 $!"  
wait $interactive43 
