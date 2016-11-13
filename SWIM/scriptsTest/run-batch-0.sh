~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-0.txt workGenOutputTest-0 -queue batch0 -map.vcores 4 -red.vcores 4 -map.memory 3072 -red.memory 2048 0.0027218233 0.26819903 >> workGenLogs/batch-0.txt 2>> workGenLogs/batch-0.txt  &  batch0=$!  
wait $batch0 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-0
# inputSize 57303500
