cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  40 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-40_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-40_0.txt  &  interactive40="$interactive40 $!"  
wait $interactive40 
