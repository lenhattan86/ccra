#!/bin/bash
rm vcore_usage_per_job.png memory_usage_per_job.png time_analysis_of_diff_jobs.png
rm ../scriptsTest/workGenLogs/vcores_used_per_job.csv
rm ../scriptsTest/workGenLogs/memory_used_per_job.csv
python get_yarn_job_info.py --master ctl.hadooptez.yarnrm-pg0.utah.cloudlab.us
python plot_job_mem_usage.py
python plot_job_vcores_usage.py
python plot_job_time_pie.py 
