sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-53.txt workGenOutputTest-530 -queue batch0 1.7869763E-5 6.46875 >> workGenLogs/job-53_0.txt 2>> workGenLogs/job-53_0.txt  &  batch53="$batch53 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-53.txt workGenOutputTest-531 -queue batch1 1.7869763E-5 6.46875 >> workGenLogs/job-53_1.txt 2>> workGenLogs/job-53_1.txt  &  batch53="$batch53 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-53.txt workGenOutputTest-532 -queue interactive 1.7869763E-5 6.46875 >> workGenLogs/job-53_interactive.txt 2>> workGenLogs/job-53.txt   &  batch53="$batch53 $!"  
wait $batch53 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-530
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-531
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-532
# inputSize 57303500
