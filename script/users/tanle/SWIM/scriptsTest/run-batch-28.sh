sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-28.txt workGenOutputTest-280 -queue batch0 3.659462E-5 0.48831666 >> workGenLogs/job-28_0.txt 2>> workGenLogs/job-28_0.txt  &  batch28="$batch28 $!"  
sleep 8 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-28.txt workGenOutputTest-281 -queue batch1 3.659462E-5 0.48831666 >> workGenLogs/job-28_1.txt 2>> workGenLogs/job-28_1.txt  &  batch28="$batch28 $!"  
wait $batch28 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-280
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-281
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-282
# inputSize 57303500
