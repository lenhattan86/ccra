cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  29 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-29_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-29_0.txt  &  interactive29="$interactive29 $!"  
wait $interactive29 
