~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-20.txt workGenOutputTest-20 -queue batch0 -map.vcores 6 -red.vcores 3 -map.memory 2048 -red.memory 3072 1.7869763E-5 1.0 >> workGenLogs/batch-20.txt 2>> workGenLogs/batch-20.txt  &  batch20=$!  
wait $batch20 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-20
# inputSize 57303500
