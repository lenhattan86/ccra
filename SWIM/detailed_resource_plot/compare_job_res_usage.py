#!/usr/bin/env python
import pandas
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import argparse
import datetime as dt
import matplotlib.ticker as ticker
import seaborn as sns

parser = argparse.ArgumentParser()
parser.add_argument('--apps', help='Application Ids to compare comma seperated', required=True)
parser.add_argument('--resource', help='Resourse usage to compare: memory or vcores', required=True)

args = vars(parser.parse_args())
resource = args['resource']
apps = args['apps']

colnames = ['id', 'timestamp', 'memory', 'vcores']
data = pandas.read_csv('../scriptsTest/workGenLogs/memory_cpu_detailed_usage.csv', names=colnames)

data = data[data['id'].isin(apps.split(','))]

data['timestamp'] = data['timestamp'] - data['timestamp'].iloc[0]
data['timestamp'] = data['timestamp'].astype(int).fillna(0)

if resource == 'vcores':
	data_to_plot = data[['timestamp', 'id', 'vcores']].groupby(['timestamp','id']).sum()
else:
	data_to_plot = data[['timestamp', 'id', 'memory']].groupby(['timestamp','id']).sum()

myplot = data_to_plot.unstack().plot(kind='bar',stacked=True,width=1.0)
for ind, label in enumerate(myplot.get_xticklabels()):
    if ind % 10 == 0:  # every 10th label is kept
        label.set_visible(True)
    else:
        label.set_visible(False)

plt.title(resource + ' comparison for applications')
plt.ylabel(resource)
plt.xlabel('Time')
plt.legend()
plt.tight_layout()
plt.savefig('job_'+resource+'_comparison.png')
