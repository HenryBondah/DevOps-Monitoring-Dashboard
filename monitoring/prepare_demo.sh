#!/bin/bash

# Week 8 System Demonstration Preparation Script
# Purpose: Prepare environment and generate scenarios for demo video recording

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$SCRIPT_DIR/../demo_materials"
LOG_DIR="$SCRIPT_DIR/../logs"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Week 8 Demonstration Preparation & Setup Script       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"

# Create demo materials directory
mkdir -p "$DEMO_DIR"
mkdir -p "$LOG_DIR"

echo -e "${GREEN}Creating demonstration materials...${NC}\n"

# ============================================================================
# Create Demo Script / Presentation Outline
# ============================================================================

cat > "$DEMO_DIR/demo_script.md" << 'EOF'
# DevOps Monitoring Dashboard - System Demonstration Script

## Video Structure (Approximately 8-10 minutes)

### 1. Introduction (1 minute)
**Script:**
"Welcome to the DevOps Monitoring Dashboard demonstration. This project showcases a comprehensive monitoring solution built with industry-standard tools including Prometheus, Grafana, Elasticsearch, and the ELK stack. Today, I'll walk you through the key features, real-time monitoring capabilities, and alerting system that make this a production-ready monitoring solution."

**Visual:**
- Show project architecture diagram
- Quick overview of tech stack

---

### 2. System Architecture Overview (1.5 minutes)
**Script:**
"The system architecture consists of multiple integrated components working together. At the core, we have Prometheus for metrics collection, scraping data from Node Exporter for system metrics and cAdvisor for container metrics. Grafana provides beautiful visualizations and dashboards. For log management, we use Filebeat to collect logs, Logstash to process them, and Elasticsearch to store and index them. Alertmanager handles intelligent alert routing and notifications."

**Visual:**
- Architecture diagram highlighting each component
- Show docker-compose.yml structure
- Display running containers with `docker ps`

**Commands to demonstrate:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

### 3. Real-Time Metrics Dashboard (2 minutes)
**Script:**
"Let's dive into the Grafana dashboard. Here we can see real-time system metrics including CPU usage, memory consumption, disk space, and network activity. The dashboard features multiple visualization types - time series graphs, gauges, and stat panels - all updating in real-time with a 10-second refresh interval."

**Visual:**
- Navigate to Grafana (http://localhost:3000)
- Show system-metrics-v2 dashboard
- Highlight key panels:
  - CPU Usage graph
  - Memory Usage gauge
  - Disk Space indicators
  - Network I/O graphs
  - Container metrics

**Interaction:**
- Change time range (last 5m, 15m, 1h)
- Use variable selectors (instance, job)
- Hover over graphs to show tooltips
- Zoom into specific time ranges

---

### 4. Alert System Demonstration (2 minutes)
**Script:**
"The monitoring system includes an intelligent alerting framework with multiple severity levels and categories. Let me show you how alerts are configured and triggered. We have critical alerts for immediate attention, warnings for potential issues, and performance alerts for optimization opportunities."

**Visual:**
- Navigate to Prometheus alerts (http://localhost:9090/alerts)
- Show configured alert rules
- Navigate to Alertmanager (http://localhost:9093)
- Display alert routing and grouping

**Generate test alert:**
```bash
# Trigger a high CPU alert
cd monitoring
./test_alerts.sh
```

**Show:**
- Alert appearing in Prometheus
- Alert propagating to Alertmanager
- Email notification format (if configured)
- Alert resolution when conditions clear

---

### 5. Log Management & Analysis (1.5 minutes)
**Script:**
"For comprehensive observability, we need both metrics and logs. The system uses the ELK stack for log aggregation and analysis. Filebeat collects logs from various sources, Logstash processes and enriches them, and Elasticsearch provides powerful search and analytics capabilities."

**Visual:**
- Show Elasticsearch indices: `curl http://localhost:9200/_cat/indices`
- Query sample logs
- Show log generation script working

**Commands:**
```bash
# Show Elasticsearch health
curl -s http://localhost:9200/_cluster/health | jq

# Query recent logs
curl -s "http://localhost:9200/logstash-*/_search?size=5" | jq '.hits.hits[]._source'
```

---

### 6. Container Monitoring (1 minute)
**Script:**
"Container monitoring is crucial in modern DevOps. Using cAdvisor, we track resource usage for each container individually - CPU, memory, network, and disk I/O. This helps identify resource bottlenecks and optimize container resource limits."

**Visual:**
- Show container metrics in Grafana
- Navigate to cAdvisor UI (http://localhost:8080)
- Display per-container resource usage
- Show container-specific alerts

---

### 7. Performance & Health Checks (1 minute)
**Script:**
"System reliability is ensured through continuous health checks and performance monitoring. Every component has health endpoints that are regularly checked. Query performance, data freshness, and service availability are all monitored automatically."

**Visual:**
- Run health check script
- Show Prometheus targets status
- Display query performance metrics
- Show service uptime indicators

**Commands:**
```bash
./week8_comprehensive_test.sh
```

---

### 8. Key Features & Insights Summary (1 minute)
**Script:**
"Let me summarize the key capabilities demonstrated:
1. Real-time monitoring with 10-second granularity
2. Multi-level alerting with intelligent routing
3. Comprehensive log aggregation and analysis
4. Container and system-level metrics
5. Beautiful, responsive dashboards
6. Production-ready configuration
7. Automated testing and validation

This monitoring solution provides complete observability for DevOps environments, enabling proactive issue detection and rapid troubleshooting."

**Visual:**
- Quick montage of key screens
- Show test results summary
- Display metrics statistics

---

## Pre-Recording Checklist

### System Preparation
- [ ] All containers are running and healthy
- [ ] Grafana dashboards are loaded and displaying data
- [ ] Prometheus has active scrape targets
- [ ] Elasticsearch cluster is healthy
- [ ] Alert rules are loaded without errors
- [ ] Test alerts can be triggered successfully
- [ ] Logs are being collected and indexed

### Visual Preparation
- [ ] Browser windows positioned correctly
- [ ] Terminal with clear, readable font (16pt+)
- [ ] Dashboard panels are arranged nicely
- [ ] Color scheme is professional
- [ ] No sensitive information visible
- [ ] Screen recording software configured (1080p minimum)

### Testing
- [ ] Run comprehensive test script
- [ ] Generate sample logs
- [ ] Trigger test alerts
- [ ] Verify all URLs are accessible
- [ ] Check that data is flowing properly

### Recording Setup
- [ ] Microphone tested and clear
- [ ] Background noise minimized
- [ ] Screen resolution set to 1920x1080
- [ ] Recording software ready (OBS, Camtasia, etc.)
- [ ] Demo script printed/available on second screen
- [ ] Water nearby for speaking comfort

---

## Post-Recording Editing Checklist

- [ ] Remove any dead air or long pauses
- [ ] Add intro title slide with project name
- [ ] Add transition effects between sections
- [ ] Include captions/subtitles for accessibility
- [ ] Add background music (soft, professional)
- [ ] Include terminal command text overlays for clarity
- [ ] Add annotation arrows/highlights for key features
- [ ] Include closing slide with:
  - GitHub repository link
  - Contact information
  - Technologies used
  - Thank you message
- [ ] Export in high quality (1080p, 60fps preferred)
- [ ] Test video playback before final submission

---

## Talking Points & Key Highlights

### Technical Sophistication
- Multi-component architecture with proper service orchestration
- Industry-standard monitoring stack (Prometheus/Grafana)
- Professional alert management with Alertmanager
- Production-grade log aggregation with ELK stack

### Practical Value
- Real-time visibility into system health
- Proactive alerting prevents downtime
- Historical data for trend analysis
- Comprehensive logging for troubleshooting

### DevOps Best Practices
- Infrastructure as code (Docker Compose)
- Configuration management (YAML files)
- Automated testing and validation
- Documentation and runbooks

### Scalability & Extensibility
- Easy to add new metrics sources
- Configurable alert thresholds
- Modular dashboard design
- Support for multiple data sources

---

## Common Demo Pitfalls to Avoid

1. **Don't rush** - Speak clearly and give viewers time to absorb information
2. **Avoid jargon** - Explain technical terms when first used
3. **Show, don't just tell** - Demonstrate features in action
4. **Prepare for failures** - Have backup plans if something doesn't work
5. **Keep it focused** - Stay on script, avoid tangents
6. **Test everything twice** - Murphy's law applies to demos
7. **Mind your cursor** - Slow, deliberate mouse movements
8. **Silence notifications** - Turn off OS notifications, emails, etc.

---

## Backup Commands & Troubleshooting

### If services are down:
```bash
cd monitoring
docker-compose down
docker-compose up -d
# Wait 30 seconds for services to start
```

### If no metrics appear:
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, health}'
```

### If alerts aren't working:
```bash
# Validate alert rules
docker exec prometheus promtool check rules /etc/prometheus/alert.rules.yml
```

### If Grafana isn't loading:
```bash
# Check Grafana logs
docker logs grafana --tail 50
```

---

## Video Recording Timeline Template

| Time | Section | Duration | Key Points |
|------|---------|----------|------------|
| 0:00 | Intro Title | 0:10 | Project name, your name |
| 0:10 | Introduction | 0:50 | Purpose, overview |
| 1:00 | Architecture | 1:30 | Components, design |
| 2:30 | Dashboard Demo | 2:00 | Real-time metrics, visualizations |
| 4:30 | Alerts | 2:00 | Alert rules, triggering, notifications |
| 6:30 | Logs | 1:30 | ELK stack, log queries |
| 8:00 | Containers | 1:00 | cAdvisor, resource monitoring |
| 9:00 | Health Checks | 1:00 | Testing, validation |
| 10:00 | Summary | 1:00 | Key features, benefits |
| 11:00 | Outro | 0:20 | Thank you, contact info |

**Total Duration: ~11-12 minutes**

EOF

echo -e "${GREEN}✓ Created demo script: $DEMO_DIR/demo_script.md${NC}"

# ============================================================================
# Create Quick Reference Card
# ============================================================================

cat > "$DEMO_DIR/quick_reference.md" << 'EOF'
# Quick Reference - URLs and Commands

## Service URLs
- **Grafana Dashboard**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Alertmanager**: http://localhost:9093
- **Node Exporter**: http://localhost:9100/metrics
- **cAdvisor**: http://localhost:8080
- **Elasticsearch**: http://localhost:9200

## Essential Commands

### Start/Stop System
```bash
cd monitoring
docker-compose up -d          # Start all services
docker-compose down           # Stop all services
docker-compose restart        # Restart all services
docker ps                     # Show running containers
```

### Health Checks
```bash
./week8_comprehensive_test.sh # Full system test
./verify_setup.sh             # Quick verification
curl http://localhost:9090/-/healthy  # Prometheus health
curl http://localhost:3000/api/health # Grafana health
```

### Generate Demo Data
```bash
./generate_logs.sh            # Generate sample logs
./test_alerts.sh              # Trigger test alerts
```

### Useful Queries
```bash
# Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, instance, health}'

# Active alerts
curl -s http://localhost:9093/api/v2/alerts | jq

# Elasticsearch indices
curl -s http://localhost:9200/_cat/indices?v

# Container stats
docker stats --no-stream
```

## Grafana Navigation
1. Login: admin/admin
2. Dashboards → Browse
3. Select "System Metrics Overview v2"
4. Use time picker (top right) to adjust time range
5. Use variable dropdowns to filter by instance/job

## Demo Flow Shortcuts
1. F11 - Fullscreen browser
2. Cmd+T - New tab
3. Cmd+Tab - Switch applications
4. Cmd+Shift+4 - Screenshot (macOS)

EOF

echo -e "${GREEN}✓ Created quick reference: $DEMO_DIR/quick_reference.md${NC}"

# ============================================================================
# Create Test Scenario Generator
# ============================================================================

cat > "$DEMO_DIR/generate_demo_scenarios.sh" << 'EOF'
#!/bin/bash

# Script to generate interesting scenarios for demo

echo "Generating demo scenarios..."

# Scenario 1: Generate sustained load
echo "1. Generating CPU load (for CPU alert demo)..."
cat > /tmp/cpu_load.sh << 'LOAD'
#!/bin/bash
# Run for 2 minutes
timeout 120 yes > /dev/null &
timeout 120 yes > /dev/null &
echo "CPU load generated (will run for 2 minutes)"
LOAD
chmod +x /tmp/cpu_load.sh

# Scenario 2: Generate memory pressure
echo "2. Generating memory pressure..."
cat > /tmp/mem_load.sh << 'LOAD'
#!/bin/bash
# Allocate ~500MB RAM
stress-ng --vm 1 --vm-bytes 500M --timeout 120s 2>/dev/null || \
python3 -c "x = ' ' * (500 * 1024 * 1024); import time; time.sleep(120)" &
echo "Memory pressure generated"
LOAD
chmod +x /tmp/mem_load.sh

# Scenario 3: Generate diverse logs
echo "3. Generating diverse log patterns..."
cat > /tmp/generate_diverse_logs.sh << 'LOGS'
#!/bin/bash
LOG_FILE="../logs/demo_app.log"

for i in {1..20}; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') INFO [Service-$((RANDOM % 5))] Processing request ID: REQ-$RANDOM" >> $LOG_FILE
  sleep 0.5
  
  if [ $((RANDOM % 10)) -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR [Service-$((RANDOM % 5))] Connection timeout to database" >> $LOG_FILE
  fi
  
  if [ $((RANDOM % 15)) -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') WARN [Service-$((RANDOM % 5))] High latency detected: $((RANDOM % 1000))ms" >> $LOG_FILE
  fi
done

echo "Diverse logs generated in $LOG_FILE"
LOGS
chmod +x /tmp/generate_diverse_logs.sh

echo ""
echo "Demo scenario scripts created in /tmp/"
echo "To execute:"
echo "  - CPU Load: /tmp/cpu_load.sh"
echo "  - Memory Load: /tmp/mem_load.sh"
echo "  - Diverse Logs: /tmp/generate_diverse_logs.sh"

EOF

chmod +x "$DEMO_DIR/generate_demo_scenarios.sh"
echo -e "${GREEN}✓ Created scenario generator: $DEMO_DIR/generate_demo_scenarios.sh${NC}"

# ============================================================================
# Create Presentation Slides Outline (Markdown)
# ============================================================================

cat > "$DEMO_DIR/presentation_slides.md" << 'EOF'
# Presentation Slides Outline

## Slide 1: Title Slide
**Content:**
- Title: "DevOps Monitoring Dashboard"
- Subtitle: "Comprehensive System Monitoring & Alerting Solution"
- Your Name
- Date

**Design:**
- Professional background
- Project logo/icon
- Clean, modern look

---

## Slide 2: Problem Statement
**Content:**
- "Why Monitoring Matters"
- Key challenges:
  - System downtime costs businesses millions
  - Reactive vs. Proactive approach
  - Need for real-time visibility
  - Log aggregation complexity

**Visual:**
- Icons representing challenges
- Statistics on downtime costs

---

## Slide 3: Solution Overview
**Content:**
- "A Comprehensive Monitoring Solution"
- Key features:
  - ✓ Real-time metrics collection
  - ✓ Intelligent alerting
  - ✓ Log aggregation & analysis
  - ✓ Beautiful visualizations
  - ✓ Container monitoring

**Visual:**
- Feature icons
- Brief bullet points

---

## Slide 4: Architecture Diagram
**Content:**
- System components and data flow
- Technologies used

**Visual:**
```
┌─────────────┐
│  Filebeat   │──→ Logstash ──→ Elasticsearch
└─────────────┘
                                      ↓
┌─────────────┐                  Grafana ←── Prometheus ←─┬─ Node Exporter
│ Application │                                            └─ cAdvisor
└─────────────┘                      ↑
                                     │
                              Alertmanager
```

---

## Slide 5: Technology Stack
**Content:**
- **Metrics Collection**: Prometheus, Node Exporter, cAdvisor
- **Visualization**: Grafana
- **Alerting**: Alertmanager
- **Logging**: ELK Stack (Elasticsearch, Logstash, Filebeat)
- **Orchestration**: Docker Compose

**Visual:**
- Technology logos
- Version numbers

---

## Slide 6: Key Metrics Monitored
**Content:**
- System Metrics: CPU, Memory, Disk, Network
- Container Metrics: Resource usage per container
- Application Metrics: Custom app metrics
- Log Analytics: Error rates, patterns

**Visual:**
- Sample graphs/charts
- Icons for each metric type

---

## Slide 7: Alert System
**Content:**
- Multi-level severity (Critical, Warning, Info)
- Smart routing and grouping
- Inhibition rules to reduce noise
- Multiple notification channels

**Visual:**
- Alert flow diagram
- Sample alert notification

---

## Slide 8: Dashboard Features
**Content:**
- Real-time updates (10s interval)
- Interactive time selection
- Variable-based filtering
- Mobile-responsive design
- Professional visualizations

**Visual:**
- Dashboard screenshot
- Highlight key panels

---

## Slide 9: Demo Highlights
**Content:**
- What we'll demonstrate:
  1. Live metrics dashboard
  2. Alert triggering and resolution
  3. Log query and analysis
  4. Container monitoring
  5. System health checks

---

## Slide 10: Results & Benefits
**Content:**
- Achieved Outcomes:
  - < 1 second query latency
  - 10-second metric granularity
  - 99.9% uptime monitoring
  - Automated alert management
  - Comprehensive observability

**Visual:**
- Metrics/statistics
- Success indicators

---

## Slide 11: Future Enhancements
**Content:**
- Planned improvements:
  - Machine learning anomaly detection
  - Distributed tracing integration
  - Custom metric exporters
  - Mobile app for alerts
  - Cloud deployment (AWS/Azure/GCP)

---

## Slide 12: Thank You / Q&A
**Content:**
- Thank you message
- Contact information
- GitHub repository link
- LinkedIn/Portfolio

**Visual:**
- Professional closing
- Contact icons

EOF

echo -e "${GREEN}✓ Created presentation outline: $DEMO_DIR/presentation_slides.md${NC}"

# ============================================================================
# Summary and Next Steps
# ============================================================================

echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Demonstration materials created successfully!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Created files:${NC}"
echo "  📄 $DEMO_DIR/demo_script.md - Complete demo script with timing"
echo "  📄 $DEMO_DIR/quick_reference.md - Quick reference for URLs and commands"
echo "  📄 $DEMO_DIR/generate_demo_scenarios.sh - Script to generate demo scenarios"
echo "  📄 $DEMO_DIR/presentation_slides.md - Presentation slides outline"

echo -e "\n${YELLOW}Next steps for demo preparation:${NC}"
echo "  1. Review the demo script and customize talking points"
echo "  2. Practice the demo 2-3 times before recording"
echo "  3. Set up screen recording software (OBS Studio recommended)"
echo "  4. Run system health checks: ./week8_comprehensive_test.sh"
echo "  5. Generate demo scenarios: $DEMO_DIR/generate_demo_scenarios.sh"
echo "  6. Configure microphone and test audio quality"
echo "  7. Record in a quiet environment"
echo "  8. Edit video with captions and transitions"

echo -e "\n${YELLOW}Recording tips:${NC}"
echo "  • Use 1920x1080 resolution minimum"
echo "  • Keep video under 12 minutes for engagement"
echo "  • Speak clearly and at a moderate pace"
echo "  • Show, don't just tell - demonstrate features"
echo "  • Use cursor highlights for important elements"
echo "  • Add background music (soft, professional)"
echo "  • Include captions for accessibility"

echo -e "\n${GREEN}Good luck with your demonstration recording!${NC}\n"

EOF

chmod +x "$DEMO_DIR/generate_demo_scenarios.sh"
echo -e "${GREEN}✓ Created demonstration preparation script${NC}"
