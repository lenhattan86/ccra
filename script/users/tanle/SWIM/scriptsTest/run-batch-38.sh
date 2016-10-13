sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 0 inputPath-batch-38.txt workGenOutputTest-380 -queue batch0 1.7869763E-5 559240.5 >> workGenLogs/job-38_0.txt 2>> workGenLogs/job-38_0.txt  &  batch38="$batch38 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 0 inputPath-batch-38.txt workGenOutputTest-381 -queue batch1 1.7869763E-5 559240.5 >> workGenLogs/job-38_1.txt 2>> workGenLogs/job-38_1.txt  &  batch38="$batch38 $!"  
wait $batch38 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-380
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-381
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-382
# inputSize 57303500
