cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  33 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-33_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-33_0.txt  &  interactive33="$interactive33 $!"  
wait $interactive33 
