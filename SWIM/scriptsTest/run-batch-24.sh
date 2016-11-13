~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-24.txt workGenOutputTest-24 -queue batch0 -map.vcores 5 -red.vcores 4 -map.memory 3072 -red.memory 6144 1.7869763E-5 1.0 >> workGenLogs/batch-24.txt 2>> workGenLogs/batch-24.txt  &  batch24=$!  
wait $batch24 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-24
# inputSize 57303500
