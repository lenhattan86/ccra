~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-29.txt workGenOutputTest-29 -queue batch1 -map.vcores 6 -red.vcores 4 -map.memory 1024 -red.memory 3072 1.7869763E-5 1.0 >> workGenLogs/batch-29.txt 2>> workGenLogs/batch-29.txt  &  batch29=$!  
wait $batch29 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-29
# inputSize 57303500
