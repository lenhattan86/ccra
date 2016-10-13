sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-32.txt workGenOutputTest-320 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-32_0.txt 2>> workGenLogs/job-32_0.txt  &  batch32="$batch32 $!"  
sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-32.txt workGenOutputTest-321 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-32_1.txt 2>> workGenLogs/job-32_1.txt  &  batch32="$batch32 $!"  
wait $batch32 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-320
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-321
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-322
# inputSize 57303500
