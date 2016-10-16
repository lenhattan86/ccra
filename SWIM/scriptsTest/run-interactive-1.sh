~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-1.txt workGenOutputTestInt-10 -queue interactive0 1.7869763E-5 1.0 >> workGenLogs/job-1_0.txt 2>> workGenLogs/job-1_0.txt  &  interactive1="$interactive1 $!"  
wait $interactive1 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-10
# inputSize 57303500
