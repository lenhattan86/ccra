from collections import OrderedDict
from pandas import DataFrame
from random import randint, sample, seed
from os import path
import os
from pandas import read_csv

import matplotlib.pyplot as plt

# TASK_EVENT_FOLDER = '/home/tanle/projects/ClusterData2011_2/clusterdata-2011-2/task_events_test'
# lastEvenTimestamp = 10622388150 # hard code this number as the last gz file is weird
TASK_EVENT_FOLDER = '/home/tanle/projects/ClusterData2011_2/clusterdata-2011-2/task_events'
lastEvenTimestamp = 2506199602822 # hard code this number as the last gz file is weird
# task_event_df = read_csv(path.join(TASK_EVENT_FOLDER, 'part-00499-of-00500.csv.gz'), header=None, index_col=False, compression='gzip', names=task_events_csv_colnames)
# print 'last even timestamp'
# print max(task_event_df['time'])


task_events_csv_colnames = ['time', 'missing', 'job_id', 'task_idx', 'machine_id', 'event_type', 'user', 'sched_cls',
                            'priority', 'cpu_requested', 'mem_requested', 'disk', 'restriction']

seed(83)
sample_moments = sorted(sample(xrange(lastEvenTimestamp+1), lastEvenTimestamp/(1000000*3600)))
snapshot_moment = randint(0, lastEvenTimestamp)
print snapshot_moment

tasks_dict = {}
samples_dicts = OrderedDict([])
sample_moments_iterator = iter(sample_moments)
current_sample_moment = next(sample_moments_iterator)
tasks_df = None

# Not the most elegant code I've ever written...
#%%time
for fn in sorted(os.listdir(TASK_EVENT_FOLDER)):
    if fn.endswith(".gz"):
            # read the gz file
            fp = path.join(TASK_EVENT_FOLDER, fn)
            task_events_df = read_csv(fp, header=None, index_col=False, compression='gzip',
                                      names=task_events_csv_colnames)
            print fp
            # for each row
            for index, event in task_events_df.iterrows():

                if current_sample_moment is not None and event['time'] > current_sample_moment:
                    tmp_tasks_df = DataFrame(tasks_dict.values())
                    samples_dicts[current_sample_moment] = ({'time' : current_sample_moment,
                                                             'cpu_requested' : sum(tmp_tasks_df.fillna(0)['cpu_requested']),
                                                             'mem_requested' : sum(tmp_tasks_df.fillna(0)['mem_requested'])})
                    try:
                        current_sample_moment = next(sample_moments_iterator)
                    except StopIteration:
                        current_sample_moment = None

                # if tasks_df is None and event['time'] > snapshot_moment:
                #     tasks_df = DataFrame(tasks_dict.values())

                # if event['event_type'] in [0, 7, 8]:
                if event['event_type'] in [1]:
                    tasks_dict[(event['job_id'], event['task_idx'])] = {'task_id' : (event['job_id'], event['task_idx']),
                                                                        'machine_id' : event['machine_id'],
                                                                        'cpu_requested' : event['cpu_requested'],
                                                                        'mem_requested' : event['mem_requested']}
                elif event['event_type'] in [2, 3, 4, 5, 6]:
                    try:
                        del tasks_dict[(event['job_id'], event['task_idx'])]
                    except KeyError as e:
                        pass
                    

            # if tasks_df is not None and current_sample_moment is None:
            #     break

    samples_df = DataFrame(samples_dicts.values())
    samples_df.to_csv('samples_df.csv', sep=',')

# fig = plt.figure()
# ax = fig.add_subplot(111)
# ax.plot(samples_df['time'], samples_df['cpu_requested'], label='cpu requested')
# ax.plot(samples_df['time'], samples_df['mem_requested'], label='mem requested')
# plt.xlim(min(samples_df['time']), max(samples_df['time']))
# plt.legend()
# plt.show()