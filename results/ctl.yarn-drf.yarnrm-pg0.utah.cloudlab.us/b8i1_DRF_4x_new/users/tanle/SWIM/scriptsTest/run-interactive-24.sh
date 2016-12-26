cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  24 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-24_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-24_0.txt  &  interactive24="$interactive24 $!"  
wait $interactive24 
