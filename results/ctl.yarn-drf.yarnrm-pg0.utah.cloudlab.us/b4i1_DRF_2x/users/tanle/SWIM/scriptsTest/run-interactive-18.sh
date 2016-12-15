cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  18 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-18_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-18_0.txt  &  interactive18="$interactive18 $!"  
wait $interactive18 
