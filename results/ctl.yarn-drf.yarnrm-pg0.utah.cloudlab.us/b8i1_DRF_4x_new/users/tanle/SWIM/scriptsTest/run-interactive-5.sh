cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  5 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-5_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-5_0.txt  &  interactive5="$interactive5 $!"  
wait $interactive5 
