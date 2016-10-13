sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-14.txt workGenOutputTest-140 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-14_0.txt 2>> workGenLogs/job-14_0.txt  &  batch14="$batch14 $!"  
sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-14.txt workGenOutputTest-141 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-14_1.txt 2>> workGenLogs/job-14_1.txt  &  batch14="$batch14 $!"  
wait $batch14 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-140
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-141
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-142
# inputSize 57303500
