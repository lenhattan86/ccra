cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  6 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-6_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-6_0.txt  &  interactive6="$interactive6 $!"  
wait $interactive6 
