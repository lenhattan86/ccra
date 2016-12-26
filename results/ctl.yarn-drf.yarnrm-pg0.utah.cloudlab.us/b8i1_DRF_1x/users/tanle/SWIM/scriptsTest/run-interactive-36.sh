cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  36 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-36_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-36_0.txt  &  interactive36="$interactive36 $!"  
wait $interactive36 
