# Usage of scripts in detailed plot section

This Folder has all the scripts to plot detailed resource usage for al the applications you are running of your cluster.
Usage of each file with example is mentioned below
Before runing any script, please run prepare.sh which installs required libraries for plotting the plots

get_yarn_detailed_job_info.py and get_yarn_job_info.py are data collection scripts.

#### get_yarn_detailed_job_info.py must be executed when the job run is initaited.
Following the plots which are generated using using this data:


### compare_job_res_usage.py: 
Compares vcores/memory taken by multiple applications overtime.

command: python compare_job_res_usage.py --apps application_1543529343414_0041,application_1543529343414_0042,application_1543529343414_0040 --resource vcores

Plot Generated: job_vcores_comparison.png

![alt text](https://github.com/ShashwatArghode/BPFImpl/blob/master/SWIM/detailed_resource_plot/job_vcores_comparison.png)


command: python compare_job_res_usage.py --apps application_1543529343414_0041,application_1543529343414_0042,application_1543529343414_0040 --resource memory

Plot Generated: job_memory_comparison.png

![alt text](https://github.com/ShashwatArghode/BPFImpl/blob/master/SWIM/detailed_resource_plot/job_memory_comparison.png)


### plot_usage_per_job.sh: Runs the job vcores seconds and memory seconds comparison for every job executed in this run and plots it.

Plots generated:

time_analysis_of_diff_jobs.png: 
![alt text](https://github.com/ShashwatArghode/BPFImpl/blob/master/SWIM/detailed_resource_plot/time_analysis_of_diff_jobs.png)

vcore_usage_per_job.png: 
![alt text](https://github.com/ShashwatArghode/BPFImpl/blob/master/SWIM/detailed_resource_plot/vcore_usage_per_job.png)

memory_usage_per_job.png: 
![alt text](https://github.com/ShashwatArghode/BPFImpl/blob/master/SWIM/detailed_resource_plot/memory_usage_per_job.png)

