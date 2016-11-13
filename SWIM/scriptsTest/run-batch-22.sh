~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-22.txt workGenOutputTest-22 -queue batch0 -map.vcores 3 -red.vcores 1 -map.memory 3072 -red.memory 5120 1.7869763E-5 1.0 >> workGenLogs/batch-22.txt 2>> workGenLogs/batch-22.txt  &  batch22=$!  
wait $batch22 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-22
# inputSize 57303500
