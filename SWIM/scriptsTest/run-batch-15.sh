~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-15.txt workGenOutputTest-15 -queue batch1 -map.vcores 4 -red.vcores 4 -map.memory 3072 -red.memory 5120 1.2824696E-4 0.44563887 >> workGenLogs/batch-15.txt 2>> workGenLogs/batch-15.txt  &  batch15=$!  
wait $batch15 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-15
# inputSize 57303500
