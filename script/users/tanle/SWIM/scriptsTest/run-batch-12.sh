sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-12.txt workGenOutputTest-120 -queue batch0 2.706641E-4 0.06602192 >> workGenLogs/job-12_0.txt 2>> workGenLogs/job-12_0.txt  &  batch12="$batch12 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-12.txt workGenOutputTest-121 -queue batch1 2.706641E-4 0.06602192 >> workGenLogs/job-12_1.txt 2>> workGenLogs/job-12_1.txt  &  batch12="$batch12 $!"  
wait $batch12 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-120
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-121
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-122
# inputSize 57303500
