#!/usr/bin/env python

# Copyright 2016 Emaad Ahmed Manzoor
# License: Apache License, Version 2.0
# http://www.eyeshalfclosed.com/

"""
Plot queue resource usage over time

Requires numpy, matplotlib.

Example usage:

    python get_yarn_queue_info.py \
            --queue root.interactive \ 
            --data yarn_queue_info.txt

    Output:
        - root.interactive-cpu.pdf
        - root.interactive-memory.pdf
"""

import argparse
import datetime
import json
import matplotlib.pyplot as plt
from matplotlib.ticker import MaxNLocator
import numpy as np
import sys
import time
import urllib2

parser = argparse.ArgumentParser()
parser.add_argument('--queue', help='YARN queue name', required=True)
parser.add_argument('--data', help='YARN queue data file', required=True)

args = vars(parser.parse_args())

queue_name = args['queue']
data_file = args['data']

timestamps = []
cpus = []
memory = []
with open(data_file, 'r') as f:
    for line in f:
        fields = line.strip().split(' ')

        if fields[1] != queue_name:
            continue

        timestamp = datetime.datetime.strptime(fields[0], "%H:%M:%S")
        # Hack if time is near midnight
        #if timestamp.hour == 0:
        #    timestamp = timestamp + datetime.timedelta(days=1)
        c = int(fields[2])
        m = int(fields[3])

        timestamps.append(timestamp)
        cpus.append(c)
        memory.append(m)

timestamps = np.array(timestamps)
start_timestamp = timestamps[0]
for i in range(timestamps.shape[0]):
    timestamps[i] = (timestamps[i] - start_timestamp).total_seconds()

cpus = np.array(cpus, dtype=int)
memory = np.array(memory)
memory = memory / 1000

plt.plot(timestamps, cpus, '-', color='#348ABD', label='CPUs (number)')
#plt.yticks(range(0,5))
plt.legend()
plt.xlabel('Time since simulation start (seconds)')
plt.ylabel('Resource usage')
plt.savefig(queue_name + '-cpu.pdf', bbox_inches='tight')
plt.clf()
plt.close()

plt.plot(timestamps, memory, '-', color='#A60628', label='Memory (GB)')
#plt.yticks(np.arange(0, 4.5, 0.5))
plt.legend()
plt.xlabel('Time since simulation start (seconds)')
plt.ylabel('Resource usage')
plt.savefig(queue_name + '-memory.pdf', bbox_inches='tight')
plt.close()
