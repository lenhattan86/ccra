sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-42.txt workGenOutputTest-420 -queue batch0 1.7869763E-5 14128.792 >> workGenLogs/job-42_0.txt 2>> workGenLogs/job-42_0.txt  &  batch42="$batch42 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-42.txt workGenOutputTest-421 -queue batch1 1.7869763E-5 14128.792 >> workGenLogs/job-42_1.txt 2>> workGenLogs/job-42_1.txt  &  batch42="$batch42 $!"  
wait $batch42 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-420
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-421
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-422
# inputSize 57303500
