sleep 5 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-52.txt workGenOutputTest-520 -queue batch0 6.1094E-4 1.637579 >> workGenLogs/job-52_0.txt 2>> workGenLogs/job-52_0.txt  &  batch52="$batch52 $!"  
sleep 10 ; ~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-batch-52.txt workGenOutputTest-521 -queue batch1 6.1094E-4 1.637579 >> workGenLogs/job-52_1.txt 2>> workGenLogs/job-52_1.txt  &  batch52="$batch52 $!"  
wait $batch52 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-520
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-521
~/hadoop/bin/hadoop fs -rm -r workGenOutputTest-522
# inputSize 57303500
