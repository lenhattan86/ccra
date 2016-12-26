cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  13 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-13_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-13_0.txt  &  interactive13="$interactive13 $!"  
wait $interactive13 
