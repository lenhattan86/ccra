~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -m 704 -r 1 inputPath-batch-1.txt workGenOutputTest-1 -queue batch1 -map.vcores 5 -red.vcores 3 -map.memory 2048 -red.memory 7168 0.0019783957 0.25418764 >> workGenLogs/batch-1.txt 2>> workGenLogs/batch-1.txt  &  batch1=$!  
wait $batch1 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-1
# inputSize 57303500
