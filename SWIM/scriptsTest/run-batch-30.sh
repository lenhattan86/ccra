~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-30.txt workGenOutputTest-30 -queue batch0 -map.vcores 6 -red.vcores 3 -map.memory 1024 -red.memory 1024 3.6109486E-4 0.06253625 >> workGenLogs/batch-30.txt 2>> workGenLogs/batch-30.txt  &  batch30=$!  
wait $batch30 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-30
# inputSize 57303500
