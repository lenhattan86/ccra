cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  0 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-0_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-0_0.txt  &  interactive0="$interactive0 $!"  
wait $interactive0 
