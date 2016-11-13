~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-32.txt workGenOutputTest-32 -queue batch0 -map.vcores 4 -red.vcores 3 -map.memory 3072 -red.memory 7168 1.7869763E-5 1.0 >> workGenLogs/batch-32.txt 2>> workGenLogs/batch-32.txt  &  batch32=$!  
wait $batch32 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-32
# inputSize 57303500
