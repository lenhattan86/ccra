sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-3.txt workGenOutputTest-30 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-3_0.txt 2>> workGenLogs/job-3_0.txt  &  batch3="$batch3 $!"  
sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-3.txt workGenOutputTest-31 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-3_1.txt 2>> workGenLogs/job-3_1.txt  &  batch3="$batch3 $!"  
wait $batch3 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-30
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-31
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-32
# inputSize 57303500
