# Week 3: Complete Monitoring Stack

## What I Did
Built full monitoring system with 8 Docker services:
- Prometheus + Alertmanager (metrics & alerts)
- Grafana (dashboards)
- Elasticsearch + Logstash + Filebeat (logs)
- Node Exporter + cAdvisor (system & container metrics)

## How to Run
```bash
cd monitoring
touch sample_app.log
docker-compose up -d
./verify_setup.sh
```

## Access
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- cAdvisor: http://localhost:8080

## Test It
```bash
./generate_logs.sh              # Make test logs
yes > /dev/null &               # Trigger CPU alert
killall yes                     # Stop test
```

## Grafana Setup (2 min)
1. Open http://localhost:3000
2. Add Elasticsearch: Configuration → Data Sources
   - URL: `http://elasticsearch:9200`
   - Index: `system-logs-*`
3. Create dashboard with queries:
   - CPU: `avg(rate(node_cpu_seconds_total{mode!="idle"}[5m])) * 100`
   - Memory: `(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100`

## What It Does
- Collects metrics from system & containers
- Stores & searches logs in Elasticsearch
- Shows real-time dashboards
- Sends alerts when CPU/memory high
- Email notifications (edit alertmanager.yml)

## Quick Commands
```bash
docker-compose ps          # Check status
docker-compose logs -f     # View logs
docker-compose restart     # Restart
docker-compose down        # Stop
```
