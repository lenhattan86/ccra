cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  10 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-10_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-10_0.txt  &  interactive10="$interactive10 $!"  
wait $interactive10 
