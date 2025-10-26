# Week 4 - Grafana Dashboard Implementation

## 🎯 Goal
Build initial Grafana dashboards to visualize real-time metrics like CPU usage, memory, and network activity with dynamic data refresh.

## ✅ What Was Done

### 1. Data Sources Configuration
- **Prometheus**: Configured for metrics collection (http://prometheus:9090)
- **Elasticsearch**: Configured for log aggregation (http://elasticsearch:9200)
- Both data sources auto-provisioned via `/monitoring/grafana/provisioning/datasources/datasources.yml`
- Auto-refresh interval: 10 seconds by default

### 2. System Metrics Overview Dashboard
Created a comprehensive dashboard with 6 panels:

**Panel 1: CPU Usage (%)**
- Query: `100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
- Visualization: Time series
- Thresholds: Green (0-70%), Yellow (70-85%), Red (85%+)

**Panel 2: Memory Usage (%)**
- Query: `(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100`
- Visualization: Gauge
- Thresholds: Green (0-60%), Yellow (60-80%), Orange (80-90%), Red (90%+)

**Panel 3: Disk Usage (%)**
- Query: `(node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} - node_filesystem_free_bytes{fstype!~"tmpfs|overlay"}) / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"} * 100`
- Visualization: Bar gauge
- Shows usage per mount point

**Panel 4: Network Traffic**
- Query (RX): `rate(node_network_receive_bytes_total{device!="lo"}[2m])`
- Query (TX): `rate(node_network_transmit_bytes_total{device!="lo"}[2m])`
- Visualization: Time series
- Unit: Bytes/sec per network device

**Panel 5: System Load (1 min average)**
- Query: `node_load1`
- Visualization: Single stat
- Shows current system load

**Panel 6: System Logs (Live Feed)**
- Data source: Elasticsearch
- Query: `process:sshd OR process:systemd`
- Visualization: Logs table
- Auto-refresh: 10 seconds

### 3. Dynamic Features
- **Auto-refresh**: Dashboard refreshes every 10 seconds
- **Time range**: Last 15 minutes (adjustable)
- **Interval variable**: Switch between 10s, 30s, 1m, 5m refresh rates
- **Real-time updates**: All panels update dynamically without page reload

## 🚀 How to Access

1. **Start the stack** (if not running):
   ```bash
   cd monitoring
   docker compose up -d
   ```

2. **Open Grafana**:
   - URL: http://localhost:3000
   - Username: `admin`
   - Password: `admin`

3. **View the dashboard**:
   - The "System Metrics Overview" dashboard loads automatically
   - Or navigate to: Dashboards → System Metrics Overview

## 🧪 Testing Dynamic Updates

### Test CPU Usage Spike:
```bash
# Install stress-ng (if not installed)
brew install stress-ng

# Run CPU stress test (2 cores for 60 seconds)
stress-ng --cpu 2 --timeout 60
```
Watch the CPU Usage panel spike in real-time.

### Test Memory Usage:
```bash
# Run memory stress test (512MB for 60 seconds)
stress-ng --vm 1 --vm-bytes 512M --timeout 60
```
Watch the Memory Usage gauge increase.

### Test Log Generation:
```bash
cd monitoring
./generate_logs.sh
```
Watch logs appear in the System Logs panel.

## 📊 What Each Panel Shows

- **CPU Usage**: Real-time CPU utilization per instance
- **Memory Usage**: Current memory consumption as percentage
- **Disk Usage**: Disk space used per filesystem
- **Network Traffic**: Network I/O (receive/transmit) per interface
- **System Load**: 1-minute load average
- **System Logs**: Live stream of system logs from Elasticsearch

## 🔄 How It Works

1. **Prometheus** scrapes metrics from Node Exporter and cAdvisor every 5 seconds
2. **Filebeat** ships logs to Logstash
3. **Logstash** processes and forwards logs to Elasticsearch
4. **Grafana** queries both Prometheus (metrics) and Elasticsearch (logs)
5. Dashboard auto-refreshes every 10 seconds to show latest data

## 📁 Configuration Files

- `/monitoring/grafana/provisioning/datasources/datasources.yml` - Auto-configures Prometheus and Elasticsearch
- `/monitoring/grafana/provisioning/dashboards/dashboards.yml` - Dashboard provisioning config
- `/monitoring/grafana/provisioning/dashboards/system-metrics.json` - System Metrics Overview dashboard definition
- `/monitoring/docker-compose.yml` - Updated with Grafana provisioning volumes

## 🎯 Week 4 Deliverables - Complete ✅

- ✅ Grafana dashboard with 6 visual panels (CPU, Memory, Disk, Network, Load, Logs)
- ✅ Dynamic auto-refresh (10s interval) working
- ✅ Real-time metric visualization
- ✅ Prometheus and Elasticsearch data sources configured
- ✅ Variable filters for time intervals
- ✅ Thresholds and color coding for alerts
- ✅ Live log feed from Elasticsearch
- ✅ Documentation complete

## 🔍 Next Steps

- Customize dashboard panels as needed
- Add more complex queries or visualizations
- Create additional dashboards for specific services
- Set up dashboard alerts for critical thresholds
