cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  26 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-26_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-26_0.txt  &  interactive26="$interactive26 $!"  
wait $interactive26 
