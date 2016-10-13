sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 2 inputPath-batch-34.txt workGenOutputTest-340 -queue batch0 1.7869763E-5 121894.05 >> workGenLogs/job-34_0.txt 2>> workGenLogs/job-34_0.txt  &  batch34="$batch34 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 2 inputPath-batch-34.txt workGenOutputTest-341 -queue batch1 1.7869763E-5 121894.05 >> workGenLogs/job-34_1.txt 2>> workGenLogs/job-34_1.txt  &  batch34="$batch34 $!"  
wait $batch34 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-340
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-341
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-342
# inputSize 57303500
