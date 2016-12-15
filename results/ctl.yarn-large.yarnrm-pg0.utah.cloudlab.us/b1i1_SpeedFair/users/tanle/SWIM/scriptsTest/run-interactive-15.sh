cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  15 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-15_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-15_0.txt  &  interactive15="$interactive15 $!"  
wait $interactive15 
