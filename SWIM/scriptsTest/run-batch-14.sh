~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-14.txt workGenOutputTest-14 -queue batch0 -map.vcores 6 -red.vcores 3 -map.memory 2048 -red.memory 4096 1.7869763E-5 2.2548828 >> workGenLogs/batch-14.txt 2>> workGenLogs/batch-14.txt  &  batch14=$!  
wait $batch14 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-14
# inputSize 57303500
