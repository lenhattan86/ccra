sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-50.txt workGenOutputTest-500 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-50_0.txt 2>> workGenLogs/job-50_0.txt  &  batch50="$batch50 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-50.txt workGenOutputTest-501 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-50_1.txt 2>> workGenLogs/job-50_1.txt  &  batch50="$batch50 $!"  
wait $batch50 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-500
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-501
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-502
# inputSize 57303500
