sleep 9 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-19.txt workGenOutputTest-190 -queue batch0 0.31931284 3.951307E-4 >> workGenLogs/job-19_0.txt 2>> workGenLogs/job-19_0.txt  &  batch19="$batch19 $!"  
sleep 6 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-19.txt workGenOutputTest-191 -queue batch1 0.31931284 3.951307E-4 >> workGenLogs/job-19_1.txt 2>> workGenLogs/job-19_1.txt  &  batch19="$batch19 $!"  
wait $batch19 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-190
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-191
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-192
# inputSize 57303500
