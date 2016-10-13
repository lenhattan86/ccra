sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-15.txt workGenOutputTest-150 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-15_0.txt 2>> workGenLogs/job-15_0.txt  &  batch15="$batch15 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-15.txt workGenOutputTest-151 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-15_1.txt 2>> workGenLogs/job-15_1.txt  &  batch15="$batch15 $!"  
wait $batch15 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-150
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-151
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-152
# inputSize 57303500
