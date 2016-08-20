#!/usr/bin/env python

import os
import sys
import time

delay = float(sys.argv[1])
folder = sys.argv[2]
i = 0
while True:
    i += 1
    print "putting file", i
    os.system("/usr/local/hadoop-2.7.1/bin/hadoop fs -put ~/bigfile2.txt /tmp/" + folder + "/bigfile" + str(i) + ".txt")
    os.system("sync")
    os.system("echo 3 > /proc/sys/vm/drop_caches")
    os.system("blockdev --flushbufs /dev/sda")
    os.system("/usr/local/hadoop-2.7.1/bin/hadoop fs -mv /tmp/" + folder + "/bigfile" + str(i) + ".txt" + " /" + folder + "/bigfile" + str(i) + ".txt")
    print "done putting file"
    time.sleep(delay)
