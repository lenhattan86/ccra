cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  41 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-41_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-41_0.txt  &  interactive41="$interactive41 $!"  
wait $interactive41 
