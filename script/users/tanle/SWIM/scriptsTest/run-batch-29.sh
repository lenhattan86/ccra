sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-29.txt workGenOutputTest-290 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-29_0.txt 2>> workGenLogs/job-29_0.txt  &  batch29="$batch29 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-29.txt workGenOutputTest-291 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-29_1.txt 2>> workGenLogs/job-29_1.txt  &  batch29="$batch29 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-29.txt workGenOutputTest-292 -queue interactive 1.7869763E-5 1.0 >> workGenLogs/job-29_interactive.txt 2>> workGenLogs/job-29.txt   &  batch29="$batch29 $!"  
wait $batch29 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-290
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-291
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-292
# inputSize 57303500
