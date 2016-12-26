cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  12 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-12_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-12_0.txt  &  interactive12="$interactive12 $!"  
wait $interactive12 
