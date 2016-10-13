sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-6.txt workGenOutputTest-60 -queue batch0 1.7869763E-5 3.5888672 >> workGenLogs/job-6_0.txt 2>> workGenLogs/job-6_0.txt  &  batch6="$batch6 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-6.txt workGenOutputTest-61 -queue batch1 1.7869763E-5 3.5888672 >> workGenLogs/job-6_1.txt 2>> workGenLogs/job-6_1.txt  &  batch6="$batch6 $!"  
wait $batch6 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-60
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-61
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-62
# inputSize 57303500
