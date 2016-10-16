sleep 7 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-0.txt workGenOutputTest-00 -queue batch0 2.7218234E-4 0.2681926 >> workGenLogs/job-0_0.txt 2>> workGenLogs/job-0_0.txt  &  batch0="$batch0 $!"  
wait $batch0 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-00
# inputSize 57303500
