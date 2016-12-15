cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  44 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-44_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-44_0.txt  &  interactive44="$interactive44 $!"  
wait $interactive44 
