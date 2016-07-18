# Flintrock Setup

Versions:

   * Spark version: 2.0.0-preview
   * YARN version: 2.7.2

Notes:

   * Ensure that the correct key name and location is in `config.yaml`.
   * Ensure that this folder is the current working directory.
   * Ensure that the correct variables are placed in `set-ec2-env.sh`.
   * nsure variables are exported with `source set-ec2-env.sh`.

## Create the cluster

```
flintrock --config config.yaml launch small
```

   * From the EC2 console, change the `flintrock` security group to open port 8088
     for anywhere. Only ports 8080-8081 are open to a custom IP by default.
   * Edit `config.yaml` to change the number of slaves.
   * Stop the cluster with `flintrock stop small`.
   * Resume the cluster with `flintrock start small`.

## Edit configuration files

In `yarn-site.xml`, update `yarn.resourcemanager.hostname` to the URL of
the master host.

## Configure the cluster

```
./flintrock-configure.sh
```
   * Verify that Spark is up by going to `master:8080`.
   * Verify that YARN is up by going to `master:8088`.

## Run the experiment

```
# login to the master
flintrock login small

# start a screen so we can detach
screen

# run the experiment with 1, 2 and 3 overlapping applications
chmod +x ./perform_experiment.sh
./perform_experiment.sh 3

# CTRL-A CTRL-D to detach
# screen -r to reattach
```

Clear disk space on the slave nodes by emptying
`/media/ephemeral0/yarn-local/usercache/ec2-user/filecache`.

Results on the master:

   * `times$i.txt` contains the times it took to run `$i` applications in parallel.
   * `appliction$i.$j` contains logs from application `$j$ when `$i` applications
     were submitted in parallel.
