sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-4.txt workGenOutputTest-40 -queue batch0 1.7869763E-5 64.049805 >> workGenLogs/job-4_0.txt 2>> workGenLogs/job-4_0.txt  &  batch4="$batch4 $!"  
sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-4.txt workGenOutputTest-41 -queue batch1 1.7869763E-5 64.049805 >> workGenLogs/job-4_1.txt 2>> workGenLogs/job-4_1.txt  &  batch4="$batch4 $!"  
wait $batch4 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-40
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-41
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-42
# inputSize 57303500
