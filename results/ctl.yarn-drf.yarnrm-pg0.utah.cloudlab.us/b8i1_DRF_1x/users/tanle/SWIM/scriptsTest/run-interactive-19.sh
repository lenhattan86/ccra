cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  19 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-19_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-19_0.txt  &  interactive19="$interactive19 $!"  
wait $interactive19 
