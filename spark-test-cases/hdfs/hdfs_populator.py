#!/usr/bin/env python

import os
import sys
import time

app = int(sys.argv[1])
delay = float(sys.argv[2])
os.system("~/hadoop/bin/hadoop fs -mkdir hdfs:///tmp")
os.system("~/hadoop/bin/hadoop fs -mkdir hdfs:///tmp/spark"+str(app))
i = 0
os.system("rm -rf ./hdfs_poulator.csv")
while True:
    print "putting file", i, "application", app, "delay", delay
    os.system("~/hadoop/bin/hadoop fs -put bigfile.txt /tmp/spark" + \
              str(app) + "/bigfile" + str(i) + ".txt")
    print "done putting file"
    os.system("date --rfc-3339=seconds >> ./hdfs_poulator.csv")
    if i == 0:
        i = 1
    elif i == 1:
        i = 2
    else:
        i = 0
    
    print "deleting file", i, "application", app, "delay", delay
    os.system("~/hadoop/bin/hadoop fs -rm /tmp/spark" + \
              str(app) + "/bigfile" + str(i) + ".txt")
    print "done deleting file"
    #os.system("sync")
    #os.system("echo 3 > /proc/sys/vm/drop_caches")
    #os.system("blockdev --flushbufs /dev/sda")

    print "sleeping seconds:", delay
    time.sleep(delay)
