sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-5.txt workGenOutputTest-50 -queue batch0 3.7798738E-5 0.47276086 >> workGenLogs/job-5_0.txt 2>> workGenLogs/job-5_0.txt  &  batch5="$batch5 $!"  
wait $batch5 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-50
# inputSize 57303500
