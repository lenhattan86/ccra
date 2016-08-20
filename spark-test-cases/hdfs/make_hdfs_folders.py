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
    os.system("~/hadoop/bin/hadoop fs -put ~/bigfile.txt /tmp/" + folder + "/bigfile" + str(i) + ".txt")
    os.system("sync")
    os.system("echo 3 > /proc/sys/vm/drop_caches")
    os.system("blockdev --flushbufs /dev/sda")
    os.system("~/hadoop/bin/hadoop fs -mv /tmp/" + folder + "/bigfile" + str(i) + ".txt" + " /" + folder + "/bigfile" + str(i) + ".txt")
    print "done putting file"
    time.sleep(delay)
