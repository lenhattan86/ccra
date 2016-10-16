#HADOOP_HOME=~/hadoop
HADOOP_HOME=../hadoop/hadoop-dist/target/hadoop-2.7.2
scriptTestFolder="scriptsTest"

# Compile MapReduce jobs
rm -rf workGen; mkdir workGen; javac -classpath $HADOOP_HOME/share/hadoop/common/\*:$HADOOP_HOME/share/hadoop/mapreduce/\*:$HADOOP_HOME/share/hadoop/mapreduce/lib/\* -d workGen WorkGen.java; jar -cvf WorkGen.jar -C workGen/ .

rm -rf $scriptTestFolder; javac GenerateReplayScript.java; java GenerateReplayScript

javac GenerateSparkScripts.java; java GenerateSparkScripts

mkdir $scriptTestFolder/workGenLogs






 

