sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-45.txt workGenOutputTest-450 -queue batch0 1.4697183E-4 0.42887676 >> workGenLogs/job-45_0.txt 2>> workGenLogs/job-45_0.txt  &  batch45="$batch45 $!"  
sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-45.txt workGenOutputTest-451 -queue batch1 1.4697183E-4 0.42887676 >> workGenLogs/job-45_1.txt 2>> workGenLogs/job-45_1.txt  &  batch45="$batch45 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-45.txt workGenOutputTest-452 -queue interactive 1.4697183E-4 0.42887676 >> workGenLogs/job-45_interactive.txt 2>> workGenLogs/job-45.txt   &  batch45="$batch45 $!"  
wait $batch45 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-450
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-451
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-452
# inputSize 57303500
