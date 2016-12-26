cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  45 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-45_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-45_0.txt  &  interactive45="$interactive45 $!"  
wait $interactive45 
