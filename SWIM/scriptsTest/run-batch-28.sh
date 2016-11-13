~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-28.txt workGenOutputTest-28 -queue batch0 -map.vcores 6 -red.vcores 2 -map.memory 3072 -red.memory 5120 3.660335E-4 0.43523243 >> workGenLogs/batch-28.txt 2>> workGenLogs/batch-28.txt  &  batch28=$!  
wait $batch28 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-28
# inputSize 57303500
