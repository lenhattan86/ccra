sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-44.txt workGenOutputTest-440 -queue batch0 1.7869763E-5 2243.1865 >> workGenLogs/job-44_0.txt 2>> workGenLogs/job-44_0.txt  &  batch44="$batch44 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-44.txt workGenOutputTest-441 -queue batch1 1.7869763E-5 2243.1865 >> workGenLogs/job-44_1.txt 2>> workGenLogs/job-44_1.txt  &  batch44="$batch44 $!"  
wait $batch44 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-440
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-441
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-442
# inputSize 57303500
