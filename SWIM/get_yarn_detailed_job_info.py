#!/usr/bin/env python

import argparse
import time
import json
import sys
import urllib2
import csv

parser = argparse.ArgumentParser()
parser.add_argument('--master', help='YARN ResourceManager URL', required=True)
parser.add_argument('--interval', help='Polling interval', required=True)
#parser.add_argument('--file', help='log file', required=True)

args = vars(parser.parse_args())

master_url = args['master']
interval = int(args['interval'])
get_apps = 'http://' + args['master'] + ':9099/ws/v1/cluster/apps'

file_name_op = './workGenLogs/memory_cpu_detailed_usage.csv'

ofile_op  = open(file_name_op, "wb")
writer_op = csv.writer(ofile_op, dialect='excel')

while True:
    try:
        response = urllib2.urlopen(get_apps)
        info_json = json.loads(response.read())
        timestamp = time.strftime("%H:%M:%S")
        for app in info_json['apps']['app']:
	    if app['state'] != "FINISHED":
                id = app['id']
                #memory = app['memorySeconds']
                #vcore = app['vcoreSeconds']
	        memory = app['allocatedMB']
                vcore = app['allocatedVCores']
                row = [id, timestamp, memory, vcore]
                writer_op.writerow(row)
        time.sleep(interval)
    except:
        print 'Could not access URL:', url
