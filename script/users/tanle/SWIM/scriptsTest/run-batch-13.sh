sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-13.txt workGenOutputTest-130 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-13_0.txt 2>> workGenLogs/job-13_0.txt  &  batch13="$batch13 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-13.txt workGenOutputTest-131 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-13_1.txt 2>> workGenLogs/job-13_1.txt  &  batch13="$batch13 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-13.txt workGenOutputTest-132 -queue interactive 1.7869763E-5 1.0 >> workGenLogs/job-13_interactive.txt 2>> workGenLogs/job-13.txt   &  batch13="$batch13 $!"  
wait $batch13 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-130
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-131
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-132
# inputSize 57303500
