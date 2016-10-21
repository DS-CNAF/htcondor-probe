#!/bin/bash
# Configure HTCondor probe and fire up supervisord

usage() {
  cat <<-EOF
	usage: $0 -ci collector-address [-c url-to-config] ...

	Configure HTCondor probe and start supervisord for this container. 
	
	OPTIONS:
	  -c collector-address  HTCondor collector address. 
	  -r inteRval		Probe interval in seconds. 15 as default.
	  -u url-to-config  	config file reference from http url. That's disable manual changes to configs.

	  -g graphite-ip	Enable graphite option. Require its endpoint.
	  -n graphite-namespace Graphite namespace
	  -m meta-namespace	Graphite meta-namespace

	  -i influxdb-ip        Enable influx option. Require its endpoint.
	  -j influx-user        Influx user credential.
	  -l influx-password    Influx password credential.
	  -d influx-db          Influx database.
	  -t influx-db-tag	extra tags to include with all metrics (comma-separated key:value)
	EOF
  exit 1
}

COLLECTOR_IP=
INTERVAL=15
URL_TO_CONFIG=

# GRAPHITE
GRAPHITE=false
GRAPHITE_IP=localhost
NAMESPACE=default.namespace
META_NAMESPACE=default.meta

# INFLUX
INFLUX_IP=localhost
INFLUX=false
INFLUX_DB=database
INFLUX_USER=user
INFLUX_PWD=pwd
TAG=null:null
while getopts ':c:u:g:n:m:i:j:l:d:t:' OPTION; do
  case $OPTION in
    c)
      [ -n "$COLLECTOR_IP" -o -z "$OPTARG" ] && usage
      COLLECTOR_IP="$OPTARG"
    ;;       
    r)
      [ -o -z "$OPTARG" ] && usage
      INTERVAL="$OPTARG"
    ;;  
    u)
      [ -n "$URL_TO_CONFIG" -o -z "$OPTARG" ] && usage
      URL_TO_CONFIG="$OPTARG"
    ;;  
    g)
      [ -z "$OPTARG" ] && usage
      GRAPHITE_IP="$OPTARG"
      GRAPHITE=true
    ;;  
    n)
      [ -z "$OPTARG" ] && usage
      NAMESPACE="$OPTARG"
    ;;  
    m)
      [ -z "$OPTARG" ] && usage
      META_NAMESPACE="$OPTARG"
    ;;  
    i)
      [ -z "$OPTARG" ] && usage
      INFLUX_IP="$OPTARG"
      INFLUX=true
    ;;  
    j)
      [ -z "$OPTARG" ] && usage
      INFLUX_USER="$OPTARG"
    ;;  
    l)
      [ -z "$OPTARG" ] && usage
      INFLUXDB_PWD="$OPTARG"
    ;;  
    h)
      [ -z "$OPTARG" ] && usage
      INFLUX_DB="$OPTARG"
    ;;  
    t)
      [ -z "$OPTARG" ] && usage
      PROBE_TAG="$OPTARG"
    ;;  
    *)
      usage
    ;;
  esac
done

# PROBE CONFIGURATION
sed -i \
  -e 's/@INTERVAL@/'"$INTERVAL"'/' \
  -e 's/@COLLECTOR_IP@/'"$COLLECTOR_IP"'/' \
  /opt/probes/etc/condor-probe.cfg

cat >> /etc/supervisor/conf.d/supervisord.conf << EOL
[program:probes]
command=/opt/probes/bin/condor_probe.py /opt/probes/etc/condor-probe.cfg
environment=INFLUXDB_PASSWORD=$INFLUX_PWD,INFLUXDB_USERNAME=$INFLUX_USER
autostart=true
EOL

# Prepare Probe configuration
sed -i \
  -e 's/@INTERVAL@/'"$INTERVAL"'/' \
  -e 's/@GRAPHITE@/'"$GRAPHITE"'/' \
  -e 's/@GRAPHITE_IP@/'"$GRAPHITE_IP"'/' \
  -e 's/@NAMESPACE@/'"$NAMESPACE"'/' \
  -e 's/@META_NAMESPACE@/'"$META_NAMESPACE"'/' \
  -e 's/@INFLUX@/'"$INFLUX"'/' \
  -e 's/@INFLUX_IP@/'"$INFLUX_IP"'/' \
  -e 's/@INFLUX_DB@/'"$INFLUX_DB"'/' \
  -e 's/@TAG@/'"$TAG"'/' \
  /opt/probes/etc/condor-probe.cfg 

# Prepare external config
if [ -n "$CONFIG_MODE" ]; then
  wget -O - "$CONFIG_URL" > /opt/probes/etc/condor-probe.cfg
fi

exec /usr/local/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
