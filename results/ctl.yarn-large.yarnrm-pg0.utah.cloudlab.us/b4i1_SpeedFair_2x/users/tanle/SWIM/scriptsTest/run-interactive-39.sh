cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  39 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-39_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-39_0.txt  &  interactive39="$interactive39 $!"  
wait $interactive39 
