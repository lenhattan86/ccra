sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-20.txt workGenOutputTest-200 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-20_0.txt 2>> workGenLogs/job-20_0.txt  &  batch20="$batch20 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-20.txt workGenOutputTest-201 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-20_1.txt 2>> workGenLogs/job-20_1.txt  &  batch20="$batch20 $!"  
wait $batch20 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-200
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-201
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-202
# inputSize 57303500
