~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-2.txt workGenOutputTestInt-20 -queue interactive0 -memory 1024 1.7869763E-5 1.0 >> workGenLogs/interactive-2_0.txt 2>> workGenLogs/interactive-2_0.txt  &  interactive2="$interactive2 $!"  
wait $interactive2 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-20
# inputSize 57303500
