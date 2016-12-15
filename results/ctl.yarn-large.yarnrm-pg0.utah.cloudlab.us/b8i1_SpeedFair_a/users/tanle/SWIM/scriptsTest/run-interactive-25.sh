cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  25 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-25_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-25_0.txt  &  interactive25="$interactive25 $!"  
wait $interactive25 
