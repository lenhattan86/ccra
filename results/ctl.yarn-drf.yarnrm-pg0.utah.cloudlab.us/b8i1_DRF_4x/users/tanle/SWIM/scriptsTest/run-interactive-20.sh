cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  20 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-20_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-20_0.txt  &  interactive20="$interactive20 $!"  
wait $interactive20 
