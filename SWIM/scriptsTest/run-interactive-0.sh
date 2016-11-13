~/hadoop/bin/hadoop jar ../WorkGen.jar org.apache.hadoop.examples.WorkGen -conf users/tanle/hadoop/conf/workGenKeyValue_conf.xsl -r 1 inputPath-interactive-0.txt workGenOutputTestInt-00 -queue interactive0 -map.vcores 2 -red.vcores 2 -map.memory 2048 -red.memory 2048 0.0027218233 0.26819903 >> workGenLogs/interactive-0_0.txt 2>> workGenLogs/interactive-0_0.txt  &  interactive0="$interactive0 $!"  
wait $interactive0 
~/hadoop/bin/hadoop fs -rm -r workGenOutputTestInt-00
# inputSize 57303500
