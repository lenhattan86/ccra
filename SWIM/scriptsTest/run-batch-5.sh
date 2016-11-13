~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-5.txt workGenOutputTest-5 -queue batch1 -map.vcores 6 -red.vcores 4 -map.memory 3072 -red.memory 5120 3.780572E-4 0.047267355 >> workGenLogs/batch-5.txt 2>> workGenLogs/batch-5.txt  &  batch5=$!  
wait $batch5 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-5
# inputSize 57303500
