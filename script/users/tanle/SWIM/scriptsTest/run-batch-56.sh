sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-56.txt workGenOutputTest-560 -queue batch0 1.7869763E-5 6510.418 >> workGenLogs/job-56_0.txt 2>> workGenLogs/job-56_0.txt  &  batch56="$batch56 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-56.txt workGenOutputTest-561 -queue batch1 1.7869763E-5 6510.418 >> workGenLogs/job-56_1.txt 2>> workGenLogs/job-56_1.txt  &  batch56="$batch56 $!"  
wait $batch56 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-560
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-561
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-562
# inputSize 57303500
