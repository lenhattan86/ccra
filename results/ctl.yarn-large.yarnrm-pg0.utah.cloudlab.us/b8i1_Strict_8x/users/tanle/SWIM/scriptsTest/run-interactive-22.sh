cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  22 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-22_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-22_0.txt  &  interactive22="$interactive22 $!"  
wait $interactive22 
