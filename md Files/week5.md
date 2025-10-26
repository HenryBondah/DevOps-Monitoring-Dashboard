# Week 5 - Advanced Dashboards, Filtering & Alerting

## 🎯 Goal
Expand dashboards with additional panels, add advanced filters and time-range controls, implement real-time alerting/notifications, and refine overall visual layout.

## ✅ What Was Done

### 1. Expanded Dashboard with 12+ Advanced Panels

Created **System Metrics Overview v2** with the following panels organized by category:

#### ⚙️ System Overview
- **CPU Usage (%)** - Overall CPU utilization with thresholds
- **Memory Usage (%)** - Memory consumption gauge
- **System Uptime** - Time since last reboot

#### 🧠 CPU & Memory Details
- **CPU Core Breakdown** - Per-core CPU usage trends
- **Process Count** - Running and blocked processes

#### 💽 Disk & I/O
- **Disk Usage (%)** - Space usage per filesystem
- **Disk I/O - Read** - Read rates per disk
- **Disk I/O - Write** - Write rates per disk

#### 🌐 Network
- **Network Traffic** - RX/TX rates per interface
- **Network Packet Loss** - Packet drops detection

#### 🐳 Containers
- **Container CPU Usage** - CPU per container
- **Container Memory Usage** - Memory per container

#### 📊 System Load & Logs
- **System Load Average** - 1/5/15 minute load averages
- **Top Log Errors** - Most frequent error messages from Elasticsearch
- **System Logs (Live Feed)** - Real-time log streaming

### 2. Advanced Filtering & Time Controls

**Dashboard Variables:**
- `$instance` - Filter by server instance
- `$job` - Filter by Prometheus job
- `$filesystem` - Filter by disk/filesystem
- `$interval` - Control data resolution (10s, 30s, 1m, 5m, 15m)

**Time Range Controls:**
- Quick-select buttons: 5m, 15m, 1h, 6h, 12h, 24h, 2d, 7d, 30d
- Custom date/time picker for historical analysis
- Auto-refresh intervals: 10s, 30s, 1m, 5m, 15m

All PromQL queries use `$instance` and `$interval` variables for dynamic filtering.

### 3. Expanded Prometheus Alert Rules

Added new alert rules in `alert.rules.yml`:

**New Alerts:**
- **DiskSpaceLow** - Triggers when available space < 15%
- **HighSystemLoad** - Triggers when 1-min load > 5
- **NetworkPacketDrops** - Triggers when network drops detected

**Existing Alerts (Refined):**
- HighCPUUsage (>80% for 2min) - Critical
- HighMemoryUsage (>75% for 5min) - Warning  
- HighDiskUsage (>85% for 5min) - Warning
- ContainerHighCPUUsage (>80% for 3min) - Warning
- ContainerHighMemoryUsage (>80% for 3min) - Warning
- ServiceDown (down for 1min) - Critical

### 4. Grafana Notification Channels

Created notification configuration (`grafana/provisioning/alerting/notifications.yml`):

**Contact Points:**
- **email-alerts** - For critical alerts
- **slack-alerts** - For warning alerts

**Notification Policies:**
- Critical severity → Email notifications
- Warning severity → Slack notifications
- Group by: alertname, severity
- Repeat interval: 4 hours

### 5. Refined Visual Layout

**Organization:**
- Panels grouped by category using collapsible rows
- Color-coded by severity (green/yellow/orange/red)
- Icon prefixes for sections (⚙️ 🧠 💽 🌐 🐳 📊)
- Consistent sizing with key metrics prominently displayed

**Visual Consistency:**
- Dark background theme
- Unified color scheme across all panels
- Threshold-based coloring for alerts
- Legend tables with mean/last/max values

**Annotations:**
- Alert markers from Prometheus
- Displays firing alerts directly on graphs

## 🚀 How to Access

1. **Start the stack** (if not running):
   ```bash
   cd monitoring
   export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
   docker compose up -d
   ```

2. **Open Grafana**:
   - URL: http://localhost:3000
   - Username: `admin`
   - Password: `admin`

3. **View dashboards**:
   - System Metrics Overview (original)
   - System Metrics Overview v2 (advanced - Week 5)

## 🧪 Testing Alerts

Use the provided test script to trigger alerts:

```bash
cd monitoring
./test_alerts.sh
```

**Test Options:**
1. Test CPU Alert - Spikes CPU to >80%
2. Test Memory Alert - Allocates memory to >75%
3. Test Load Alert - Creates processes to increase load >5
4. Test All Alerts - Runs all tests sequentially
5. Check Current Alerts - Shows active Prometheus alerts

### Manual Testing

**CPU Stress:**
```bash
# Simple CPU stress (no external tools needed)
yes > /dev/null & PID1=$!
yes > /dev/null & PID2=$!
# Stop with: kill $PID1 $PID2
```

**Memory Stress:**
```bash
# Generate memory pressure
stress_memory() {
    arr=()
    for i in {1..1000000}; do
        arr+=("$i: test string")
    done
    sleep 300
}
stress_memory &
```

**System Load:**
```bash
# Create multiple busy processes
for i in {1..8}; do
    (while true; do :; done) &
done
# Stop all: killall bash
```

## 📊 What Each New Panel Shows

- **CPU Core Breakdown**: Individual core utilization (helpful for multi-core systems)
- **Disk I/O Speed**: Read/write throughput per disk (identifies I/O bottlenecks)
- **Network Packet Loss**: Dropped packets (network reliability issues)
- **Top Log Errors**: Most frequent error messages (quick problem identification)
- **Process Count**: Running/blocked processes (system health indicator)
- **System Uptime**: Uptime duration (stability metric)
- **Container Resources**: Per-container CPU/memory (Docker monitoring)

## 🔄 How It Works

1. **Prometheus** scrapes metrics from Node Exporter, cAdvisor, and other exporters
2. **Alert Rules** evaluate conditions every 30 seconds
3. **Alertmanager** receives fired alerts and routes them
4. **Grafana** visualizes alerts and sends notifications via contact points
5. **Dashboard** auto-refreshes every 10 seconds with live data
6. **Variables** allow dynamic filtering across all panels

## 📁 New Configuration Files

- `/monitoring/grafana/provisioning/dashboards/system-metrics-v2.json` - Advanced dashboard
- `/monitoring/grafana/provisioning/alerting/notifications.yml` - Notification config
- `/monitoring/alert.rules.yml` - Updated with 3 new alert rules
- `/monitoring/test_alerts.sh` - Alert testing script

## 🎯 Week 5 Deliverables - Complete ✅

- ✅ Expanded dashboard with 15 panels (12+ requirement met)
- ✅ Dynamic filters: instance, job, filesystem, interval variables
- ✅ Advanced time controls with quick-select and custom ranges
- ✅ 9 Prometheus alert rules (3 new + 6 existing)
- ✅ Grafana notification channels configured
- ✅ Refined UI with rows, colors, icons, and annotations
- ✅ Alert testing script for validation
- ✅ Complete documentation

## 📈 Dashboard Comparison

### Version 1 (Week 4):
- 6 basic panels
- No variables
- Fixed time range
- Basic visualization

### Version 2 (Week 5):
- 15 advanced panels
- 4 dynamic variables
- Flexible time controls
- Organized layout with rows
- Container monitoring
- Error log aggregation
- Per-core CPU tracking
- Disk I/O metrics
- Network packet loss
- Alert annotations

## 🔍 Next Steps

**Configure Notifications:**
1. Go to Grafana → Alerting → Contact points
2. Update email address in `email-alerts`
3. Add Slack webhook URL in `slack-alerts` (optional)
4. Test notification delivery

**Customize Alerts:**
- Adjust thresholds in `alert.rules.yml` based on your system
- Add custom alerts for specific services
- Configure additional notification channels (Discord, PagerDuty, etc.)

**Create Additional Dashboards:**
- Application-specific metrics
- Business metrics
- Custom service monitoring

## 🎓 Key Learnings

- **Variables** make dashboards reusable across multiple instances
- **Row organization** improves dashboard readability
- **Threshold coloring** provides instant visual feedback
- **Alert annotations** show correlation between alerts and metrics
- **Dynamic intervals** balance detail vs. performance
- **Grouped alerts** reduce notification fatigue

## 📸 Screenshots

To capture screenshots for your submission:
1. Open http://localhost:3000
2. Navigate to System Metrics Overview v2
3. Run `./test_alerts.sh` and select option 1 (CPU Alert)
4. Capture: Dashboard overview, CPU panel with alert, Alerting page
5. Stop the stress test
6. Capture: Alert resolution in dashboard

## 🎬 Demo Recording

Record a 1-minute demo showing:
1. Dashboard overview with all panels
2. Variable filtering in action
3. Alert triggering (run CPU stress)
4. Alert appearing in dashboard
5. Alert showing in Prometheus /alerts page
6. Alert resolution after stopping stress
