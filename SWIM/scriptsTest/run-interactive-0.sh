~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-0.txt workGenOutputTestInt-00 -queue interactive0 2.7218234E-4 0.2681926 >> workGenLogs/job-0_0.txt 2>> workGenLogs/job-0_0.txt  &  interactive0="$interactive0 $!"  
wait $interactive0 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-00
# inputSize 57303500
