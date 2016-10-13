sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-41.txt workGenOutputTest-410 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-41_0.txt 2>> workGenLogs/job-41_0.txt  &  batch41="$batch41 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-41.txt workGenOutputTest-411 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-41_1.txt 2>> workGenLogs/job-41_1.txt  &  batch41="$batch41 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-41.txt workGenOutputTest-412 -queue interactive 1.7869763E-5 1.0 >> workGenLogs/job-41_interactive.txt 2>> workGenLogs/job-41.txt   &  batch41="$batch41 $!"  
wait $batch41 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-410
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-411
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-412
# inputSize 57303500
