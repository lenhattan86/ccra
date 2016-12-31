cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  3 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-3_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-3_0.txt  &  interactive3="$interactive3 $!"  
wait $interactive3 
