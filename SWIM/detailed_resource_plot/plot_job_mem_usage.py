#!/usr/bin/env python
import pandas
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

colnames = ['id', 'memory']
data = pandas.read_csv('../scriptsTest/workGenLogs/memory_used_per_job.csv', names=colnames)

ids = data.id.tolist()
memory = data.memory.tolist()

y_pos = np.arange(len(ids))

plt.figure(figsize=(25,25))
# Create bars
plt.barh(y_pos, memory)

# Add title and axis names
plt.title('Memory usage per application')
plt.xlabel('Memory-Seconds')
plt.ylabel('Applications')
 
# Create names on the x-axis
plt.yticks(y_pos, ids)
 
# Show graphic
plt.savefig('memory_usage_per_job.png')
