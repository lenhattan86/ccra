#!/usr/bin/env python

# Copyright 2016 Emaad Ahmed Manzoor
# License: Apache License, Version 2.0
# http://www.eyeshalfclosed.com/

"""
Get YARN queue info at regular intervals: 
   - For each queue, prints the usedResources (memory, vCores).
   - Tested on YARN 2.7.2.

Example usage:

    python get_yarn_queue_info.py \
            --interval 1
            --master ec2-52-40-144-150.us-west-2.compute.amazonaws.com \

    Output (timestamp, queue name, used memory, used vcores):

        18:36:55 root.default 4096 2
        18:36:55 root.interactive 1024 2
        18:36:56 root.default 4096 3
        18:36:56 root.interactive 1024 1
        ...
"""

import argparse
import time
import json
import sys
import urllib2
import csv

# parser = argparse.ArgumentParser()
# parser.add_argument('--master', help='YARN ResourceManager URL', required=True)
# parser.add_argument('--file', help='log file', required=True)
# 
# args = vars(parser.parse_args())

# master_url = args['master']
master_url='nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us'
url = 'http://' + master_url + ':8088/ws/v1/cluster/apps'
# file_name = args['file']
file_name='yarn_jobs.csv'

ofile  = open(file_name, "wb")
writer = csv.writer(ofile, dialect='excel')

try:
    response = urllib2.urlopen(url)
except:
    print 'Could not access URL:', url
    sys.exit(-1)

info_json = json.loads(response.read())
for app in info_json['apps']['app']:
    id = app['id']
    queue = app['queue']
    startedTime = app['startedTime']
    name= app['name']
    elapsedTime = app['elapsedTime']
    row = [id, startedTime, queue, name, elapsedTime]
    print row
#     writer.writerow(row)
