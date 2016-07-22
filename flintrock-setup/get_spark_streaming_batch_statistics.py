#!/usr/bin/env python

# Copyright 2016 Emaad Ahmed Manzoor
# License: Apache License, Version 2.0
# http://www.eyeshalfclosed.com/

"""
Get Spark Streaming microbatch statistics:
    - Batch start time
    - Scheduling delay (in seconds) for each microbatch
    - Processing time (in seconds) for each microbatch

Tested on Spark 2.0.0 running on YARN 2.7.2.

Time deltas are naive, do not run close to midnight (yet!).

Example usage:

    python get_spark_streaming_batch_statistics.py \
            --master ec2-52-40-144-150.us-west-2.compute.amazonaws.com \
            --applicationId application_1469205272660_0006

    Output (batch start time, processing time, scheduling delay):

        18:36:55 3.991 3783.837
        18:36:56 4.001 3786.832
        18:36:57 3.949 3789.862
        ...
"""

import argparse
import datetime
import json
import re
import sys
import urllib2

parser = argparse.ArgumentParser()
parser.add_argument('--master', help='YARN ResourceManager URL', required=True)
parser.add_argument('--applicationId', help='YARN application ID', required=True)

args = vars(parser.parse_args())

master_url = args['master']
application_id = args['applicationId']
stats_url = 'http://' + args['master'] + ':8088' + '/proxy/' + application_id +\
            '/api/v1/applications/' + application_id + '/jobs/' 

try:
    response = urllib2.urlopen(stats_url)
except:
    print 'Could not access URL:', stats_url
    sys.exit(-1)

batch_regex = re.compile(r'.*id=(\d+).*batch time (\d\d:\d\d:\d\d).*')

stats_json = json.loads(response.read())
batch_stats = {}
for job in stats_json:
    status = job['status']
    if status != 'SUCCEEDED':
        continue # only stats for finished jobs
    
    if not 'description' in job:
        continue # job needs a batch start time

    job_stats = {}

    description = job['description']
    matches = batch_regex.match(description).groups()
    batch_id = int(matches[0])
    batch_time = datetime.datetime.strptime(matches[1], "%H:%M:%S").time() 

    if not batch_id in batch_stats:
        batch_stats[batch_id] = {'timestamp': batch_time, 'jobs': []}

    job_stats = {'submissionTime':
                    datetime.datetime.strptime(job['submissionTime'],
                                               '%Y-%m-%dT%H:%M:%S.%f%Z').time(),
                 'completionTime':
                    datetime.datetime.strptime(job['completionTime'],
                                               '%Y-%m-%dT%H:%M:%S.%f%Z').time()}
    batch_stats[batch_id]['jobs'].append(job_stats)

for batch_id, stats in sorted(batch_stats.iteritems()):
    batch_start_time = stats['timestamp']
    jobs = stats['jobs']
    jobs = sorted(jobs, key=lambda x: x['submissionTime'])

    scheduling_delay = datetime.datetime.combine(datetime.datetime(1,1,1,0,0,0),
                                                 jobs[0]['submissionTime']) -\
                       datetime.datetime.combine(datetime.datetime(1,1,1,0,0,0),
                                                 batch_start_time)

    processing_time = datetime.datetime.combine(datetime.datetime(1,1,1,0,0,0),
                                                jobs[-1]['completionTime']) -\
                      datetime.datetime.combine(datetime.datetime(1,1,1,0,0,0),
                                                jobs[0]['submissionTime'])

    print batch_start_time,
    print processing_time.total_seconds(),
    print scheduling_delay.total_seconds()
