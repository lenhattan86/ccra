#!/usr/bin/env python
import pandas
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

colnames = ['job_type', 'total_time_elapsed']
data = pandas.read_csv('../scriptsTest/workGenLogs/total_time_batch_int.csv', names=colnames)

labels = data.job_type.tolist()
sizes = data.total_time_elapsed.tolist()

fig, ax = plt.subplots(figsize=(6, 3), subplot_kw=dict(aspect="equal"))
def func(pct, allvals):
    absolute = int(pct/100.*np.sum(allvals))
    return "{:.1f}%\n({:d} mins)".format(pct, absolute)

wedges, texts, autotexts = ax.pie(sizes, autopct=lambda pct: func(pct, sizes),
                                  textprops=dict(color="w"))

ax.legend(wedges, labels,
          title="Job Type",
          loc="center left",
          bbox_to_anchor=(1, 0, 0.5, 1))

plt.setp(autotexts, size=8, weight="bold")

ax.set_title("Elapsed Time Comparison for Batch and Interative Jobs")

plt.savefig('time_analysis_of_diff_jobs.png')
