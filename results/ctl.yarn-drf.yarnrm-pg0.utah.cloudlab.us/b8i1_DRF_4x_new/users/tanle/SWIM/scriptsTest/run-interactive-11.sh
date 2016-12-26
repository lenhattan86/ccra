cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  11 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-11_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-11_0.txt  &  interactive11="$interactive11 $!"  
wait $interactive11 
