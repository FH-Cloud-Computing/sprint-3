#!/bin/bash

set -e

curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

mkdir -p /srv/service-discovery/
chmod a+rwx /srv/service-discovery/
mkdir -p /srv/grafana/
chmod a+rwx /srv/grafana/

# Write Prometheus config
cat <<EOCF >/srv/prometheus.yml
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'exoscale'
    file_sd_configs:
      - files:
          - /srv/service-discovery/config.json
        refresh_interval: 10s
EOCF

# Write Grafana data source
cat <<EOCF >/srv/grafana-prometheus.yaml
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  orgId: 1
  url: http://prometheus:9090
  version: 1
  editable: false
EOCF

# Write Grafana filesystem dashboard source
cat <<EOCF >/srv/grafana-dashboard-provisioner.yaml
apiVersion: 1

providers:
- name: 'Home'
  orgId: 1
  folder: ''
  type: file
  updateIntervalSeconds: 10
  options:
    path: /etc/grafana/dashboards
EOCF

cat <<EOCF >/srv/grafana-dashboard.json
${grafana_dashboard}
EOCF

cat <<EOCF >/srv/grafana-notifier.yaml
${grafana_notifier}
EOCF

# Create the network
docker network create monitoring

# Run service discovery agent
docker run \
    -d \
    --name sd \
    --network monitoring \
    -v /srv/service-discovery:/var/run/prometheus-sd-exoscale-instance-pools \
    janoszen/prometheus-sd-exoscale-instance-pools:1.0.0 \
    --exoscale-api-key ${exoscale_key} \
    --exoscale-api-secret ${exoscale_secret} \
    --exoscale-zone-id ${exoscale_zone_id} \
    --instance-pool-id ${instance_pool_id}

# Run Prometheus
docker run -d \
    -p 9090:9090 \
    --name prometheus \
    --network monitoring \
    -v /srv/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v /srv/service-discovery/:/srv/service-discovery/ \
    prom/prometheus

# Run Grafana
docker run -d \
    -p 3000:3000 \
    --name grafana \
    --network monitoring \
    -v /srv/grafana-prometheus.yaml:/etc/grafana/provisioning/datasources/prometheus.yaml \
    -v /srv/grafana-dashboard-provisioner.yaml:/etc/grafana/provisioning/dashboards/filesystem.yaml \
    -v /srv/grafana-dashboard.json:/etc/grafana/dashboards/default.json \
    -v /srv/grafana-notifier.yaml:/etc/grafana/provisioning/notifiers/autoscaling.yaml \
    -v /srv/grafana/:/var/lib/grafana/ \
    grafana/grafana

# Run the autoscaler
docker run -d \
    -p 8090:8090 \
    --name autoscaler \
    --network monitoring \
    janoszen/exoscale-grafana-autoscaler:1.0.2 \
    --exoscale-api-key ${exoscale_key} \
    --exoscale-api-secret ${exoscale_secret} \
    --exoscale-zone-id ${exoscale_zone_id} \
    --instance-pool-id ${instance_pool_id}
