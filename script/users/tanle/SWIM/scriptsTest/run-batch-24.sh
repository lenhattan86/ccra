sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-24.txt workGenOutputTest-240 -queue batch0 1.7869763E-5 1.0 >> workGenLogs/job-24_0.txt 2>> workGenLogs/job-24_0.txt  &  batch24="$batch24 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-24.txt workGenOutputTest-241 -queue batch1 1.7869763E-5 1.0 >> workGenLogs/job-24_1.txt 2>> workGenLogs/job-24_1.txt  &  batch24="$batch24 $!"  
wait $batch24 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-240
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-241
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-242
# inputSize 57303500
