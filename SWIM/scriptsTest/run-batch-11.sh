~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-11.txt workGenOutputTest-11 -queue batch1 -map.vcores 3 -red.vcores 2 -map.memory 3072 -red.memory 6144 1.7869763E-5 1.0 >> workGenLogs/batch-11.txt 2>> workGenLogs/batch-11.txt  &  batch11=$!  
wait $batch11 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-11
# inputSize 57303500
