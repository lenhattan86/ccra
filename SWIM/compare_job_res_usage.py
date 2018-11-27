#!/usr/bin/env python
import pandas
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import argparse
import datetime as dt

parser = argparse.ArgumentParser()
parser.add_argument('--apps', help='Application Ids to compare comma seperated', required=True)
parser.add_argument('--resource', help='Resourse usage to compare: memory or vcores', required=True)

args = vars(parser.parse_args())
resource = args['resource']
apps = args['apps']

colnames = ['id', 'timestamp', 'memory', 'vcores']
data = pandas.read_csv('./scriptsTest/workGenLogs/memory_cpu_detailed_usage.csv', names=colnames)

for app in apps.split(','):
  tmp =  data[data['id'] == app]
  dates = tmp.timestamp.tolist()
  x = [dt.datetime.strptime(date, '%H:%M:%S') for date in dates]
  if resource == 'vcores':
    y = tmp.vcores.tolist()
  else:
    y = tmp.memory.tolist()
  plt.plot(x, y, label=app)

plt.xticks(rotation='vertical')
# Add title and axis names
plt.title(resource + ' comparison for applications')
plt.ylabel(resource)
plt.xlabel('Time')
plt.tight_layout()

plt.legend()
plt.savefig('job_'+resource+'_comparison.png')
