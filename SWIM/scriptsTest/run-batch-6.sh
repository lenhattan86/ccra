~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-6.txt workGenOutputTest-6 -queue batch0 -map.vcores 3 -red.vcores 5 -map.memory 2048 -red.memory 5120 1.7869763E-5 35.8916 >> workGenLogs/batch-6.txt 2>> workGenLogs/batch-6.txt  &  batch6=$!  
wait $batch6 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-6
# inputSize 57303500
