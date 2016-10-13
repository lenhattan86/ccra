sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-18.txt workGenOutputTest-180 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-18_0.txt 2>> workGenLogs/job-18_0.txt  &  batch18="$batch18 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-18.txt workGenOutputTest-181 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-18_1.txt 2>> workGenLogs/job-18_1.txt  &  batch18="$batch18 $!"  
wait $batch18 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-180
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-181
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-182
# inputSize 57303500
