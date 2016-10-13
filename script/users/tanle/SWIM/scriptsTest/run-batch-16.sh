sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-16.txt workGenOutputTest-160 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-16_0.txt 2>> workGenLogs/job-16_0.txt  &  batch16="$batch16 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-16.txt workGenOutputTest-161 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-16_1.txt 2>> workGenLogs/job-16_1.txt  &  batch16="$batch16 $!"  
wait $batch16 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-160
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-161
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-162
# inputSize 57303500
