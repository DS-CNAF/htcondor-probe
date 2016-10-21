# HTCondor Docker containers 

HTCondor probe relying on [fifemon/probes](https://github.com/fifemon/probes).
Ubuntu Trusty LTS is the base image used and condor version refer to the [last stable version](https://research.cs.wisc.edu/htcondor/ubuntu/).

Supervisord is used in order to control different processes spawn.

## Architecture

![Architettura HTCondor](architecture.png)

## Feature
* [simple Run](#node-run)
* [usage](#usage)

### Node run

```bash 
[root@nessun-ricordo-1 HTCondor-probe]# docker run dscnaf/htcondor-probe -c 192.168.0.129 -g 131.154.96.190 -n nessun-ricordo.htcondor -m clusterone
2016-10-21 10:03:31,089 CRIT Supervisor running as root (no user in config file)
2016-10-21 10:03:31,111 INFO supervisord started with pid 5
2016-10-21 10:03:32,114 INFO spawned: 'stdout' with pid 11
2016-10-21 10:03:32,116 INFO spawned: 'probes' with pid 12
2016-10-21 10:03:33,297 INFO success: stdout entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
2016-10-21 10:03:33,297 INFO success: probes entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
 
```


## Usage

```
        usage: $0 -ci collector-address [-c url-to-config] ...

        Configure HTCondor probe and start supervisord for this container. 
        
        OPTIONS:
          -c collector-address  HTCondor collector address. 
          -r inteRval           Probe interval in seconds. 15 as default.
          -u url-to-config      config file reference from http url. That's disable manual changes to configs.

          -g graphite-ip        Enable graphite option. Require its endpoint.
          -n graphite-namespace Graphite namespace
          -m meta-namespace     Graphite meta-namespace

          -i influxdb-ip        Enable influx option. Require its endpoint.
          -j influx-user        Influx user credential.
          -l influx-password    Influx password credential.
          -d influx-db          Influx database.
          -t influx-db-tag      extra tags to include with all metrics (comma-separated key:value)

```
