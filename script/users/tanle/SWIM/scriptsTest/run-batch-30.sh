sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-30.txt workGenOutputTest-300 -queue batch0 3.6105997E-5 0.49492508 >> workGenLogs/job-30_0.txt 2>> workGenLogs/job-30_0.txt  &  batch30="$batch30 $!"  
sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-30.txt workGenOutputTest-301 -queue batch1 3.6105997E-5 0.49492508 >> workGenLogs/job-30_1.txt 2>> workGenLogs/job-30_1.txt  &  batch30="$batch30 $!"  
wait $batch30 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-300
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-301
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-302
# inputSize 57303500
