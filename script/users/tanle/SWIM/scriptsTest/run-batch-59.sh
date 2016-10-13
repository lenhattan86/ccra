sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-59.txt workGenOutputTest-590 -queue batch0 1.7869763E-5 6510.422 >> workGenLogs/job-59_0.txt 2>> workGenLogs/job-59_0.txt  &  batch59="$batch59 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-59.txt workGenOutputTest-591 -queue batch1 1.7869763E-5 6510.422 >> workGenLogs/job-59_1.txt 2>> workGenLogs/job-59_1.txt  &  batch59="$batch59 $!"  
wait $batch59 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-590
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-591
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-592
# inputSize 57303500
