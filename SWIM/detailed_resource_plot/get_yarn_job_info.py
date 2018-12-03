#!/usr/bin/env python

import argparse
import time
import json
import sys
import urllib2
import csv

parser = argparse.ArgumentParser()
parser.add_argument('--master', help='YARN ResourceManager URL', required=True)
#parser.add_argument('--file', help='log file', required=True)

args = vars(parser.parse_args())

master_url = args['master']
get_apps = 'http://' + args['master'] + ':9099/ws/v1/cluster/apps'
file_name_mem = '../scriptsTest/workGenLogs/memory_used_per_job.csv'
file_name_vcores = '../scriptsTest/workGenLogs/vcores_used_per_job.csv'
file_name_total_time = '../scriptsTest/workGenLogs/total_time_batch_int.csv'

batch_time = 0
int_time = 0

ofile_mem  = open(file_name_mem, "wb")
writer_mem = csv.writer(ofile_mem, dialect='excel')

ofile_vcores  = open(file_name_vcores, "wb")
writer_vcores = csv.writer(ofile_vcores, dialect='excel')

ofile_total_time  = open(file_name_total_time, "wb")
writer_total_time = csv.writer(ofile_total_time, dialect='excel')

response = urllib2.urlopen(get_apps)
info_json = json.loads(response.read())

for app in info_json['apps']['app']:
    id = app['id']
    memorySeconds = app['memorySeconds']
    vcoreSeconds = app['vcoreSeconds']
    rowMem = [id, memorySeconds]
    rowvCores = [id, vcoreSeconds]
    writer_mem.writerow(rowMem)
    writer_vcores.writerow(rowvCores)
    if "batch" in app['queue']:
      batch_time += app['elapsedTime']
    else:
      int_time += app['elapsedTime']

rowTime = ['Batch Time', batch_time/1000/60]
writer_total_time.writerow(rowTime)
rowTime = ['Interactive Time', int_time/1000/60]
writer_total_time.writerow(rowTime)
