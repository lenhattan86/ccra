~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 3 inputPath-batch-31.txt workGenOutputTest-31 -queue batch1 -map.vcores 7 -red.vcores 2 -map.memory 2048 -red.memory 7168 3.0853312 8.2159234E-4 >> workGenLogs/batch-31.txt 2>> workGenLogs/batch-31.txt  &  batch31=$!  
wait $batch31 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-31
# inputSize 69586601
