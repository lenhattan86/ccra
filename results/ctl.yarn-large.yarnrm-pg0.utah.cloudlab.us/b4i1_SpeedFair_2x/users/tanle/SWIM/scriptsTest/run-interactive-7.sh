cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  7 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-7_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-7_0.txt  &  interactive7="$interactive7 $!"  
wait $interactive7 
