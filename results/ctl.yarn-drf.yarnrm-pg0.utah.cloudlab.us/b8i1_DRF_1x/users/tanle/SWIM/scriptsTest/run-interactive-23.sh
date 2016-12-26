cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  23 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-23_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-23_0.txt  &  interactive23="$interactive23 $!"  
wait $interactive23 
