#!/usr/bin/env bash
source "set-ec2-env.sh"

# Stop Spark
flintrock run-command small '/home/ec2-user/spark/sbin/stop-all.sh' --master-only

# Stop YARN
flintrock run-command small '/home/ec2-user/hadoop/sbin/stop-yarn.sh' --master-only
flintrock run-command small '/home/ec2-user/hadoop/sbin/stop-dfs.sh' --master-only

# Copy configuration
flintrock copy-file small fair-scheduler.xml /home/ec2-user/hadoop/conf/fair-scheduler.xml
flintrock copy-file small yarn-site.xml /home/ec2-user/hadoop/conf/yarn-site.xml
flintrock copy-file small spark-defaults.conf /home/ec2-user/spark/conf/spark-defaults.conf

# Install Spark-Yarn shuffle service
flintrock run-command small 'cp ~/spark/lib/spark-1.6.1-yarn-shuffle.jar ~/hadoop/share/hadoop/yarn/'

# Start Spark
flintrock run-command small '/home/ec2-user/spark/sbin/start-all.sh' --master-only

# Start YARN
flintrock run-command small '/home/ec2-user/hadoop/sbin/start-dfs.sh' --master-only
flintrock run-command small '/home/ec2-user/hadoop/sbin/start-yarn.sh' --master-only

# Copy experiment
flintrock copy-file small perform_experiment.sh /home/ec2-user/perform_experiment.sh
