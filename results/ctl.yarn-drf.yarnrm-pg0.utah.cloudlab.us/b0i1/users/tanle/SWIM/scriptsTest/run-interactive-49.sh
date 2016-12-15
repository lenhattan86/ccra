cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  49 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-49_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-49_0.txt  &  interactive49="$interactive49 $!"  
wait $interactive49 
