sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-37.txt workGenOutputTest-370 -queue batch0 1.7869763E-5 59753.93 >> workGenLogs/job-37_0.txt 2>> workGenLogs/job-37_0.txt  &  batch37="$batch37 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-37.txt workGenOutputTest-371 -queue batch1 1.7869763E-5 59753.93 >> workGenLogs/job-37_1.txt 2>> workGenLogs/job-37_1.txt  &  batch37="$batch37 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-37.txt workGenOutputTest-372 -queue interactive 1.7869763E-5 59753.93 >> workGenLogs/job-37_interactive.txt 2>> workGenLogs/job-37.txt   &  batch37="$batch37 $!"  
wait $batch37 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-370
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-371
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-372
# inputSize 57303500
