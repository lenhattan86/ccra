cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  8 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-8_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-8_0.txt  &  interactive8="$interactive8 $!"  
wait $interactive8 
