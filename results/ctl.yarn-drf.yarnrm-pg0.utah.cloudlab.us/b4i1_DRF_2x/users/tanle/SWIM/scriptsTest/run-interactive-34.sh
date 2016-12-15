cd ~/ 
~/hadoop/bin/hadoop jar ~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob  34 bursty0 >> ~/SWIM/scriptsTest/workGenLogs/interactive-34_0.txt 2>> ~/SWIM/scriptsTest/workGenLogs/interactive-34_0.txt  &  interactive34="$interactive34 $!"  
wait $interactive34 
