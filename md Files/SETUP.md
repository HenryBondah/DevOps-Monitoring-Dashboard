# Setup & Start Guide

## Prerequisites
- Docker Desktop installed and running
- macOS with 4GB+ RAM
- At least 10GB free disk space

## Quick Start (If Docker Already Installed)

```bash
# 1. Navigate to project
cd "/Users/deanonearth/Desktop/Senoir project Folder/DevOps-Monitoring-Dashboard/monitoring"

# 2. Stop any conflicting services (Week 2 Homebrew services)
brew services stop node_exporter prometheus grafana filebeat

# 3. Start all services
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
docker compose up -d

# 4. Verify everything is running (wait 30 seconds)
./verify_setup.sh
```

## First Time Setup

### 1. Install Docker Desktop

**Option A: Download Manually**
```bash
open https://www.docker.com/products/docker-desktop
```

**Option B: Via Homebrew**
```bash
brew install --cask docker
```

After installation:
- Open Docker Desktop from Applications
- Wait for whale icon to appear in menu bar (Docker is running)

### 2. Add Docker to PATH (Important!)

```bash
# Add to your ~/.zshrc file
echo 'export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Or just run this before docker commands:
```bash
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
```

### 3. Navigate to Project

```bash
cd "/Users/deanonearth/Desktop/Senoir project Folder/DevOps-Monitoring-Dashboard/monitoring"
```

### 4. Stop Conflicting Services

If you ran Week 2 setup with Homebrew:
```bash
brew services stop node_exporter
brew services stop prometheus
brew services stop grafana
brew services stop filebeat
```

### 5. Start All Services

```bash
docker compose up -d
```

This starts 8 containers:
- Prometheus (metrics database)
- Alertmanager (alert routing)
- Grafana (dashboards)
- Elasticsearch (log storage)
- Logstash (log processing)
- Filebeat (log shipping)
- Node Exporter (system metrics)
- cAdvisor (container metrics)

### 6. Verify Setup

Wait 30 seconds for services to start, then:

```bash
./verify_setup.sh
```

You should see all services marked with ✓

## Access Your Dashboards

Once running, open these URLs in your browser:

| Service | URL | Login | What It Does |
|---------|-----|-------|--------------|
| **Grafana** | http://localhost:3000 | admin/admin | Main dashboard - visualize metrics & logs |
| **Prometheus** | http://localhost:9090 | none | Query metrics, view alerts |
| **Alertmanager** | http://localhost:9093 | none | Manage & route alerts |
| **cAdvisor** | http://localhost:8080 | none | View container resource usage |
| **Elasticsearch** | http://localhost:9200 | none | Query logs directly (API) |

## How It Works

### Data Flow

```
System Metrics:
  Your Mac → Node Exporter → Prometheus → Grafana
  
Container Metrics:
  Docker Containers → cAdvisor → Prometheus → Grafana
  
Logs:
  sample_app.log → Filebeat → Logstash → Elasticsearch → Grafana
  
Alerts:
  Prometheus (triggers) → Alertmanager → Email/Slack
```

### What Each Service Does

1. **Node Exporter** - Collects CPU, memory, disk stats from your Mac
2. **cAdvisor** - Monitors Docker container resources (CPU, memory per container)
3. **Prometheus** - Stores all metrics and evaluates alert rules
4. **Filebeat** - Reads log files and ships them to Logstash
5. **Logstash** - Parses and enriches logs before storing
6. **Elasticsearch** - Stores logs in searchable format
7. **Grafana** - Creates dashboards combining metrics and logs
8. **Alertmanager** - Routes alerts to email/Slack when thresholds exceeded

## Setup Grafana (First Time - 2 minutes)

### 1. Open Grafana
```bash
open http://localhost:3000
```
Login: `admin` / `admin` (will ask to change password)

### 2. Add Elasticsearch Data Source

- Go to: **Configuration** (⚙️) → **Data Sources** → **Add data source**
- Select: **Elasticsearch**
- Configure:
  - **URL:** `http://elasticsearch:9200`
  - **Index name:** `system-logs-*`
  - **Time field name:** `@timestamp`
  - **Version:** `8.0+`
- Click **Save & Test** (should show green checkmark)

### 3. Create Your First Dashboard

- Go to: **Dashboards** → **New Dashboard** → **Add new panel**

**Panel 1: CPU Usage**
- Query type: Prometheus
- Query:
  ```
  avg by(instance) (rate(node_cpu_seconds_total{mode!="idle"}[5m])) * 100
  ```
- Panel title: "CPU Usage %"
- Unit: Percent (0-100)

**Panel 2: Memory Usage**
- Query type: Prometheus
- Query:
  ```
  (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
  ```
- Panel title: "Memory Usage %"
- Unit: Percent (0-100)

**Panel 3: System Logs**
- Query type: Elasticsearch
- Visualization: **Logs**
- Query: `*` (shows all logs)

Click **Save dashboard**

## Quick Test

### Test 1: Generate Logs
```bash
cd monitoring
./generate_logs.sh
```

Check logs arrived in Elasticsearch:
```bash
curl "http://localhost:9200/system-logs-*/_count"
```

### Test 2: Trigger CPU Alert
```bash
# Start high CPU load
yes > /dev/null &

# Wait 2-3 minutes, then check alerts
open http://localhost:9090/alerts

# Stop the test
killall yes
```

You should see "HighCPUUsage" alert go from PENDING → FIRING → RESOLVED

### Test 3: View in Grafana
- Open http://localhost:3000
- Go to your dashboard
- Metrics should update in real-time
- Logs panel should show recent entries

## Common Commands

```bash
# Check if services are running
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
docker compose ps

# View logs from all services
docker compose logs -f

# View logs from specific service
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f logstash

# Restart all services
docker compose restart

# Restart specific service
docker compose restart prometheus

# Stop all services
docker compose down

# Stop and remove all data (fresh start)
docker compose down -v

# Start services again
docker compose up -d

# Generate test logs
./generate_logs.sh

# Verify everything is working
./verify_setup.sh
```

## Understanding the Output

### When you run `verify_setup.sh`:

- **✓ Running** = Container is up
- **✓ UP** = Service is responding to health checks
- **Active targets: 3** = Prometheus is scraping 3 metric sources
- **Alert rules loaded: 10** = Your alert rules are active
- **Firing alerts: 0** = No current issues (healthy system)

### When you run `docker compose ps`:

- **STATUS: Up** = Container running normally
- **STATUS: health: starting** = Still initializing (wait a bit)
- **PORTS: 0.0.0.0:3000->3000/tcp** = Service accessible at localhost:3000

## Troubleshooting

### Docker command not found

**Problem:** `zsh: command not found: docker`

**Solution:**
```bash
# Option 1: Add to PATH temporarily
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

# Option 2: Add to PATH permanently
echo 'export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Docker not running

**Problem:** `Cannot connect to the Docker daemon`

**Solution:**
```bash
# Open Docker Desktop
open -a Docker

# Wait for whale icon in menu bar (Docker is ready)
```

### Port already in use

**Problem:** `bind: address already in use`

**Solution:**
```bash
# Stop Homebrew services (Week 2 setup)
brew services stop node_exporter prometheus grafana filebeat

# Or kill specific port (replace 3000 with your port)
lsof -ti:3000 | xargs kill -9

# Restart docker services
docker compose down
docker compose up -d
```

### Services won't start

**Problem:** Containers keep restarting or failing

**Solution:**
```bash
# Check logs for errors
docker compose logs

# Check specific service
docker compose logs elasticsearch
docker compose logs logstash

# Common fix: Clean restart
docker compose down -v
docker system prune -f
docker compose up -d
```

### No metrics showing in Prometheus

**Problem:** Graphs are empty

**Solution:**
```bash
# Check Prometheus targets
open http://localhost:9090/targets

# All should show "UP" - if not, restart that service
docker compose restart node-exporter
docker compose restart cadvisor
```

### No logs in Elasticsearch

**Problem:** No logs appearing

**Solution:**
```bash
# Check log file exists
ls -la sample_app.log

# Create if missing
touch sample_app.log

# Add test log
echo "$(date) INFO Test message" >> sample_app.log

# Check filebeat is running
docker compose logs filebeat

# Restart log pipeline
docker compose restart filebeat logstash

# Check logs arrived (wait 30 seconds)
curl "http://localhost:9200/system-logs-*/_count"
```

### Grafana not loading

**Problem:** Can't access http://localhost:3000

**Solution:**
```bash
# Check Grafana is running
docker compose ps grafana

# View Grafana logs
docker compose logs grafana

# Restart Grafana
docker compose restart grafana

# Wait 10 seconds then try again
open http://localhost:3000
```

### Need to reset everything

**Nuclear option - starts completely fresh:**
```bash
# Stop and remove everything
docker compose down -v

# Remove all Docker data (careful!)
docker system prune -a -f

# Start fresh
docker compose up -d
```

## Next Steps

1. ✅ **Open Grafana:** http://localhost:3000
2. ✅ **Add Elasticsearch data source** (see Setup Grafana section)
3. ✅ **Create your first dashboard** (CPU, Memory, Logs panels)
4. 📧 **Configure email alerts** (optional - edit alertmanager.yml)
5. 📊 **Explore Prometheus:** http://localhost:9090
6. 🐳 **Check container stats:** http://localhost:8080

## What You've Built

You now have a complete monitoring system that:

✅ Collects system metrics (CPU, memory, disk, network)  
✅ Monitors Docker containers  
✅ Aggregates and searches logs  
✅ Displays real-time dashboards  
✅ Sends alerts when problems occur  
✅ Can scale to monitor multiple servers  

**Congratulations! Your monitoring dashboard is running!** 🎉
