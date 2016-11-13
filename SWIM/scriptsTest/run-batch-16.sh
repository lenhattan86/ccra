~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-16.txt workGenOutputTest-16 -queue batch0 -map.vcores 4 -red.vcores 3 -map.memory 2048 -red.memory 4096 1.7869763E-5 1.0 >> workGenLogs/batch-16.txt 2>> workGenLogs/batch-16.txt  &  batch16=$!  
wait $batch16 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-16
# inputSize 57303500
