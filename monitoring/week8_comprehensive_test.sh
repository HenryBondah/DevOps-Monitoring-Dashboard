#!/bin/bash

# Week 8 Comprehensive System Testing Script
# Purpose: Final debugging and validation of all components

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/week8_test_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$SCRIPT_DIR/../logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

test_result() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ $1 -eq 0 ]; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        success "$2"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        error "$2"
    fi
}

# Banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Week 8 Comprehensive System Testing & Debugging Suite   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

log "Starting comprehensive system testing..."

# ============================================================================
# SECTION 1: Container Health Checks (4 hrs - Debugging and Testing)
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SECTION 1: Container Health & Service Availability${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}\n"

REQUIRED_CONTAINERS=("prometheus" "alertmanager" "grafana" "node-exporter" "cadvisor" "elasticsearch" "logstash" "filebeat")

log "Checking Docker daemon..."
if docker info > /dev/null 2>&1; then
    test_result 0 "Docker daemon is running"
else
    test_result 1 "Docker daemon is not running"
    error "Please start Docker daemon and retry"
    exit 1
fi

log "Checking container status..."
for container in "${REQUIRED_CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        STATUS=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null)
        HEALTH=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no healthcheck")
        
        if [ "$STATUS" = "running" ]; then
            test_result 0 "Container '$container' is running (Health: $HEALTH)"
        else
            test_result 1 "Container '$container' is not running (Status: $STATUS)"
        fi
    else
        test_result 1 "Container '$container' not found"
    fi
done

# Check container resource usage
log "Checking container resource usage..."
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | tee -a "$LOG_FILE"

# ============================================================================
# SECTION 2: Service Endpoint Testing
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SECTION 2: Service Endpoint & API Testing${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}\n"

# Test Prometheus
log "Testing Prometheus API..."
if curl -sf http://localhost:9090/-/healthy > /dev/null 2>&1; then
    test_result 0 "Prometheus health endpoint is accessible"
else
    test_result 1 "Prometheus health endpoint failed"
fi

if curl -sf http://localhost:9090/api/v1/targets > /dev/null 2>&1; then
    test_result 0 "Prometheus targets API is accessible"
    
    # Check target status
    TARGETS_UP=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | select(.health=="up") | .labels.job' | wc -l)
    TARGETS_DOWN=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | select(.health=="down") | .labels.job' | wc -l)
    
    log "Prometheus targets: $TARGETS_UP up, $TARGETS_DOWN down"
    
    if [ "$TARGETS_DOWN" -eq 0 ]; then
        test_result 0 "All Prometheus targets are healthy"
    else
        test_result 1 "$TARGETS_DOWN Prometheus targets are down"
    fi
else
    test_result 1 "Prometheus targets API failed"
fi

# Test Alertmanager
log "Testing Alertmanager API..."
if curl -sf http://localhost:9093/-/healthy > /dev/null 2>&1; then
    test_result 0 "Alertmanager health endpoint is accessible"
else
    test_result 1 "Alertmanager health endpoint failed"
fi

if curl -sf http://localhost:9093/api/v2/alerts > /dev/null 2>&1; then
    test_result 0 "Alertmanager alerts API is accessible"
    
    ACTIVE_ALERTS=$(curl -s http://localhost:9093/api/v2/alerts | jq '. | length')
    log "Active alerts: $ACTIVE_ALERTS"
else
    test_result 1 "Alertmanager alerts API failed"
fi

# Test Grafana
log "Testing Grafana API..."
if curl -sf http://localhost:3000/api/health > /dev/null 2>&1; then
    test_result 0 "Grafana health endpoint is accessible"
else
    test_result 1 "Grafana health endpoint failed"
fi

# Test with authentication
GRAFANA_AUTH="admin:admin"
if curl -sf -u "$GRAFANA_AUTH" http://localhost:3000/api/datasources > /dev/null 2>&1; then
    test_result 0 "Grafana datasources API is accessible"
    
    DATASOURCES=$(curl -s -u "$GRAFANA_AUTH" http://localhost:3000/api/datasources | jq '. | length')
    log "Configured datasources: $DATASOURCES"
else
    test_result 1 "Grafana datasources API failed"
fi

# Test Node Exporter
log "Testing Node Exporter..."
if curl -sf http://localhost:9100/metrics > /dev/null 2>&1; then
    test_result 0 "Node Exporter metrics endpoint is accessible"
    
    METRICS_COUNT=$(curl -s http://localhost:9100/metrics | grep -c "^node_" || echo "0")
    log "Node Exporter is exposing $METRICS_COUNT node metrics"
else
    test_result 1 "Node Exporter metrics endpoint failed"
fi

# Test cAdvisor
log "Testing cAdvisor..."
if curl -sf http://localhost:8080/healthz > /dev/null 2>&1; then
    test_result 0 "cAdvisor health endpoint is accessible"
else
    test_result 1 "cAdvisor health endpoint failed"
fi

# Test Elasticsearch
log "Testing Elasticsearch..."
if curl -sf http://localhost:9200/_cluster/health > /dev/null 2>&1; then
    test_result 0 "Elasticsearch cluster health endpoint is accessible"
    
    ES_STATUS=$(curl -s http://localhost:9200/_cluster/health | jq -r '.status')
    log "Elasticsearch cluster status: $ES_STATUS"
    
    if [ "$ES_STATUS" = "green" ] || [ "$ES_STATUS" = "yellow" ]; then
        test_result 0 "Elasticsearch cluster is healthy ($ES_STATUS)"
    else
        test_result 1 "Elasticsearch cluster is unhealthy ($ES_STATUS)"
    fi
else
    test_result 1 "Elasticsearch cluster health endpoint failed"
fi

# ============================================================================
# SECTION 3: Data Flow Verification
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SECTION 3: Data Flow & Integration Testing${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}\n"

log "Verifying Prometheus → Grafana data flow..."
# Query a simple metric through Prometheus
CPU_METRIC=$(curl -s http://localhost:9090/api/v1/query?query=node_cpu_seconds_total | jq -r '.status')
if [ "$CPU_METRIC" = "success" ]; then
    test_result 0 "Prometheus can query CPU metrics successfully"
else
    test_result 1 "Prometheus CPU metric query failed"
fi

log "Verifying Filebeat → Logstash → Elasticsearch data flow..."
# Check if Elasticsearch has indices
ES_INDICES=$(curl -s http://localhost:9200/_cat/indices?format=json | jq '. | length')
if [ "$ES_INDICES" -gt 0 ]; then
    test_result 0 "Elasticsearch has $ES_INDICES indices (logs are being ingested)"
else
    warning "Elasticsearch has no indices yet (may need more time to ingest logs)"
fi

# Check Logstash stats
if curl -sf http://localhost:9600/_node/stats > /dev/null 2>&1; then
    EVENTS_IN=$(curl -s http://localhost:9600/_node/stats | jq -r '.events.in // 0')
    EVENTS_OUT=$(curl -s http://localhost:9600/_node/stats | jq -r '.events.out // 0')
    log "Logstash events: $EVENTS_IN in, $EVENTS_OUT out"
    
    if [ "$EVENTS_OUT" -gt 0 ]; then
        test_result 0 "Logstash is processing events"
    else
        warning "Logstash hasn't processed events yet"
    fi
fi

# ============================================================================
# SECTION 4: Alert System Validation
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SECTION 4: Alert System & Notification Testing${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}\n"

log "Checking Prometheus alert rules..."
RULES_RESPONSE=$(curl -s http://localhost:9090/api/v1/rules)
RULES_STATUS=$(echo "$RULES_RESPONSE" | jq -r '.status')

if [ "$RULES_STATUS" = "success" ]; then
    test_result 0 "Prometheus alert rules loaded successfully"
    
    TOTAL_RULES=$(echo "$RULES_RESPONSE" | jq '[.data.groups[].rules[]] | length')
    FIRING_ALERTS=$(echo "$RULES_RESPONSE" | jq '[.data.groups[].rules[] | select(.state=="firing")] | length')
    PENDING_ALERTS=$(echo "$RULES_RESPONSE" | jq '[.data.groups[].rules[] | select(.state=="pending")] | length')
    
    log "Alert rules: $TOTAL_RULES total, $FIRING_ALERTS firing, $PENDING_ALERTS pending"
else
    test_result 1 "Failed to load Prometheus alert rules"
fi

log "Validating alert rule syntax..."
docker exec prometheus promtool check rules /etc/prometheus/alert.rules.yml > /dev/null 2>&1
test_result $? "Alert rules syntax validation"

log "Testing alert notification routes..."
AM_CONFIG=$(curl -s http://localhost:9093/api/v2/status)
if [ -n "$AM_CONFIG" ]; then
    test_result 0 "Alertmanager configuration is accessible"
else
    test_result 1 "Alertmanager configuration check failed"
fi

# ============================================================================
# SECTION 5: Dashboard Validation
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SECTION 5: Dashboard & Visualization Validation${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}\n"

log "Checking Grafana dashboards..."
DASHBOARDS=$(curl -s -u "$GRAFANA_AUTH" http://localhost:3000/api/search?type=dash-db | jq '. | length')
if [ "$DASHBOARDS" -gt 0 ]; then
    test_result 0 "Grafana has $DASHBOARDS dashboard(s) configured"
    
    # List dashboards
    curl -s -u "$GRAFANA_AUTH" http://localhost:3000/api/search?type=dash-db | jq -r '.[] | "  - \(.title) (UID: \(.uid))"' | tee -a "$LOG_FILE"
else
    test_result 1 "No Grafana dashboards found"
fi

log "Validating dashboard JSON syntax..."
for dashboard in "$SCRIPT_DIR/grafana/provisioning/dashboards"/*.json; do
    if [ -f "$dashboard" ]; then
        if jq empty "$dashboard" 2>/dev/null; then
            test_result 0 "Dashboard JSON syntax valid: $(basename "$dashboard")"
        else
            test_result 1 "Dashboard JSON syntax invalid: $(basename "$dashboard")"
        fi
    fi
done

# ============================================================================
# SECTION 6: Performance Testing
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SECTION 6: Performance & Resource Analysis${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}\n"

log "Measuring query performance..."
START_TIME=$(date +%s%N)
curl -s http://localhost:9090/api/v1/query?query=up > /dev/null
END_TIME=$(date +%s%N)
QUERY_TIME=$(( ($END_TIME - $START_TIME) / 1000000 ))

log "Prometheus query latency: ${QUERY_TIME}ms"
if [ "$QUERY_TIME" -lt 1000 ]; then
    test_result 0 "Prometheus query performance is good (< 1s)"
else
    warning "Prometheus query is slow (${QUERY_TIME}ms)"
fi

log "Checking disk usage..."
df -h | grep -E "Filesystem|/$" | tee -a "$LOG_FILE"

log "Checking memory usage..."
free -h | tee -a "$LOG_FILE"

# ============================================================================
# SECTION 7: Configuration Validation
# ============================================================================

echo -e "\n${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}SECTION 7: Configuration File Validation${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}\n"

log "Validating Prometheus configuration..."
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml > /dev/null 2>&1
test_result $? "Prometheus configuration syntax"

log "Validating Alertmanager configuration..."
docker exec alertmanager amtool check-config /etc/alertmanager/alertmanager.yml > /dev/null 2>&1
test_result $? "Alertmanager configuration syntax"

log "Validating Docker Compose configuration..."
docker-compose -f "$SCRIPT_DIR/docker-compose.yml" config > /dev/null 2>&1
test_result $? "Docker Compose configuration syntax"

# ============================================================================
# Test Summary
# ============================================================================

echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

echo -e "Total Tests:  ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"

PASS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
echo -e "Pass Rate:    ${YELLOW}${PASS_RATE}%${NC}\n"

if [ "$FAILED_TESTS" -eq 0 ]; then
    success "All tests passed! System is ready for production."
    echo -e "\n${GREEN}✓ System Status: READY FOR DEMONSTRATION${NC}\n"
else
    warning "$FAILED_TESTS test(s) failed. Please review the issues above."
    echo -e "\n${YELLOW}⚠ System Status: REQUIRES ATTENTION${NC}\n"
fi

log "Full test report saved to: $LOG_FILE"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

exit 0
