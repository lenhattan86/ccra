cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  30 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-30_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-30_0.txt  &  interactive30="$interactive30 $!"  
wait $interactive30 
