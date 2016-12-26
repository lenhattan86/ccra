cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  21 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-21_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-21_0.txt  &  interactive21="$interactive21 $!"  
wait $interactive21 
