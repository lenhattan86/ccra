sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 2 inputPath-batch-54.txt workGenOutputTest-540 -queue batch0 1.7869763E-5 103302.82 >> workGenLogs/job-54_0.txt 2>> workGenLogs/job-54_0.txt  &  batch54="$batch54 $!"  
sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 2 inputPath-batch-54.txt workGenOutputTest-541 -queue batch1 1.7869763E-5 103302.82 >> workGenLogs/job-54_1.txt 2>> workGenLogs/job-54_1.txt  &  batch54="$batch54 $!"  
wait $batch54 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-540
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-541
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-542
# inputSize 57303500
