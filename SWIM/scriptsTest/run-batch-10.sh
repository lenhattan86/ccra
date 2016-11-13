~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-10.txt workGenOutputTest-10 -queue batch0 -map.vcores 7 -red.vcores 1 -map.memory 3072 -red.memory 6144 1.7869763E-5 2.6992188 >> workGenLogs/batch-10.txt 2>> workGenLogs/batch-10.txt  &  batch10=$!  
wait $batch10 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-10
# inputSize 57303500
