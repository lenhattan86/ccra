cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  27 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-27_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-27_0.txt  &  interactive27="$interactive27 $!"  
wait $interactive27 
