sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-43.txt workGenOutputTest-430 -queue batch0 0.008168681 0.29772866 >> workGenLogs/job-43_0.txt 2>> workGenLogs/job-43_0.txt  &  batch43="$batch43 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-43.txt workGenOutputTest-431 -queue batch1 0.008168681 0.29772866 >> workGenLogs/job-43_1.txt 2>> workGenLogs/job-43_1.txt  &  batch43="$batch43 $!"  
wait $batch43 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-430
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-431
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-432
# inputSize 57303500
