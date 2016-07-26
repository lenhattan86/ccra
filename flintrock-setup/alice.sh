#!/usr/bin/env bash 

# ./alice.sh [number of SparkPi iterations] [sleep time in seconds]

SPARK_COMMAND="./spark/bin/spark-submit --master yarn --class org.apache.spark.examples.SparkPi --deploy-mode cluster"
SPARK_OPTS="--driver-memory 512M --executor-memory 512M"
SPARK_JAR="./spark/examples/jars/spark-examples*.jar $1"

for i in `seq 1 4`;
do
  >&2 echo "Running application $i..."
  FULL_COMMAND="$SPARK_COMMAND $SPARK_OPTS --queue interactive $SPARK_JAR"
  (TIMEFORMAT='%R'; time $FULL_COMMAND 2>application$i) 2> $i.time &
  
  >&2 echo "Sleeping for $2 s..."
  sleep $2
done

cat *.time > times.txt
rm *.time
