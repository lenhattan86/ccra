cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  31 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-31_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-31_0.txt  &  interactive31="$interactive31 $!"  
wait $interactive31 
