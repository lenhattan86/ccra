~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 8 inputPath-batch-38.txt workGenOutputTest-38 -queue batch0 -map.vcores 6 -red.vcores 3 -map.memory 2048 -red.memory 6144 1.7869763E-5 5592405.0 >> workGenLogs/batch-38.txt 2>> workGenLogs/batch-38.txt  &  batch38=$!  
wait $batch38 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-38
# inputSize 57303500
