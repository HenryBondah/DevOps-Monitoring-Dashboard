# Week 2: Basic Monitoring Setup

## What I Did
Installed 4 monitoring tools using Homebrew:
- Prometheus (metrics database)
- Node Exporter (system stats)
- Grafana (dashboards)
- Filebeat (log shipper)

## How to Run
```bash
brew services start prometheus
brew services start node_exporter
brew services start grafana
brew services start filebeat
```

## Access
- Prometheus: http://localhost:9090
- Node Exporter: http://localhost:9100/metrics
- Grafana: http://localhost:3000 (admin/admin)

## What It Does
- Collects CPU, memory, disk metrics
- Stores metrics in Prometheus
- Shows basic dashboards in Grafana
- Ready for Week 3 expansion
