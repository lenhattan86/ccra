~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-3.txt workGenOutputTest-3 -queue batch1 -map.vcores 4 -red.vcores 4 -map.memory 1024 -red.memory 4096 1.7869763E-5 1.0 >> workGenLogs/batch-3.txt 2>> workGenLogs/batch-3.txt  &  batch3=$!  
wait $batch3 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-3
# inputSize 57303500
