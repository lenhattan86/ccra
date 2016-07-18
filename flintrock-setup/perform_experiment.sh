#!/usr/bin/env bash 

SPARK_COMMAND="./spark/bin/spark-submit --master yarn --class org.apache.spark.examples.SparkPi --deploy-mode cluster"
SPARK_OPTS="--driver-memory 512M --executor-memory 512M"
SPARK_JAR="./spark/lib/spark-examples-*.jar 1000"

for i in `seq 1 $1`;
do
  >&2 echo "Running $i applications in parallel..."
  
  for j in `seq 1 $i`;
  do
    >&2 echo "	Starting application $j."
    FULL_COMMAND="$SPARK_COMMAND $SPARK_OPTS --queue q$j $SPARK_JAR"
    #FULL_COMMAND="sleep 1"
    (TIMEFORMAT='%R'; time $FULL_COMMAND 2>application$i\.$j) 2> $j.time &
  done
  >&2 echo "Waiting for all applications to finish..."
  wait

  cat *.time > times$i.txt
  rm *.time

  sleep 60
done
