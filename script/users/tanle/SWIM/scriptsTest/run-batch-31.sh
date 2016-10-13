sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-31.txt workGenOutputTest-310 -queue batch0 0.37466773 8.215737E-4 >> workGenLogs/job-31_0.txt 2>> workGenLogs/job-31_0.txt  &  batch31="$batch31 $!"  
sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-31.txt workGenOutputTest-311 -queue batch1 0.37466773 8.215737E-4 >> workGenLogs/job-31_1.txt 2>> workGenLogs/job-31_1.txt  &  batch31="$batch31 $!"  
wait $batch31 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-310
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-311
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-312
# inputSize 57303500
