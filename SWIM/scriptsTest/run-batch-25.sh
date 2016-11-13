~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-25.txt workGenOutputTest-25 -queue batch1 -map.vcores 4 -red.vcores 5 -map.memory 2048 -red.memory 5120 0.052115194 1.6002479 >> workGenLogs/batch-25.txt 2>> workGenLogs/batch-25.txt  &  batch25=$!  
wait $batch25 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-25
# inputSize 57303500
