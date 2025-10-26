#!/bin/bash

# Week 3 Monitoring Stack - Quick Start Script
# This script helps verify all components are working correctly

set -e

echo "🚀 DevOps Monitoring Dashboard - Week 3 Verification"
echo "======================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a service is responding
check_service() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    echo -n "Checking $name... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected_code"; then
        echo -e "${GREEN}✓ UP${NC}"
        return 0
    else
        echo -e "${RED}✗ DOWN${NC}"
        return 1
    fi
}

# Function to check Docker container status
check_container() {
    local container=$1
    
    echo -n "Checking container $container... "
    
    if docker ps | grep -q "$container"; then
        echo -e "${GREEN}✓ Running${NC}"
        return 0
    else
        echo -e "${RED}✗ Not running${NC}"
        return 1
    fi
}

echo "📦 Checking Docker Containers:"
echo "------------------------------"
check_container "prometheus"
check_container "alertmanager"
check_container "grafana"
check_container "node-exporter"
check_container "cadvisor"
check_container "elasticsearch"
check_container "logstash"
check_container "filebeat"
echo ""

echo "🌐 Checking Service Endpoints:"
echo "------------------------------"
check_service "Prometheus" "http://localhost:9090/-/healthy"
check_service "Alertmanager" "http://localhost:9093/-/healthy"
check_service "Grafana" "http://localhost:3000/api/health"
check_service "Node Exporter" "http://localhost:9100/metrics"
check_service "cAdvisor" "http://localhost:8080/healthz"
check_service "Elasticsearch" "http://localhost:9200/_cluster/health"
echo ""

echo "🎯 Checking Prometheus Targets:"
echo "--------------------------------"
targets_up=$(curl -s http://localhost:9090/api/v1/targets | grep -o '"health":"up"' | wc -l | tr -d ' ')
echo "Active targets: $targets_up"
if [ "$targets_up" -ge 3 ]; then
    echo -e "${GREEN}✓ Expected targets are UP${NC}"
else
    echo -e "${YELLOW}⚠ Some targets may be down${NC}"
fi
echo ""

echo "📋 Checking Alert Rules:"
echo "------------------------"
rules_loaded=$(curl -s http://localhost:9090/api/v1/rules | grep -o '"name":' | wc -l | tr -d ' ')
echo "Alert rules loaded: $rules_loaded"
if [ "$rules_loaded" -ge 3 ]; then
    echo -e "${GREEN}✓ Alert rules loaded successfully${NC}"
else
    echo -e "${YELLOW}⚠ Alert rules may not be loaded${NC}"
fi
echo ""

echo "📊 Checking Elasticsearch Indices:"
echo "-----------------------------------"
curl -s "http://localhost:9200/_cat/indices?v" | head -n 5
echo ""

echo "🔔 Checking Active Alerts:"
echo "--------------------------"
active_alerts=$(curl -s http://localhost:9090/api/v1/alerts | grep -o '"state":"firing"' | wc -l | tr -d ' ')
echo "Firing alerts: $active_alerts"
if [ "$active_alerts" -eq 0 ]; then
    echo -e "${GREEN}✓ No active alerts (system healthy)${NC}"
else
    echo -e "${YELLOW}⚠ $active_alerts alert(s) currently firing${NC}"
fi
echo ""

echo "📈 Quick Stats:"
echo "---------------"
echo "Prometheus uptime: $(curl -s http://localhost:9090/api/v1/query?query=up | grep -o '"value":\[.*\]' | cut -d'[' -f2 | cut -d',' -f2 | tr -d ']')"
echo ""

echo "🌍 Service URLs:"
echo "----------------"
echo "Prometheus:    http://localhost:9090"
echo "Alertmanager:  http://localhost:9093"
echo "Grafana:       http://localhost:3000 (admin/admin)"
echo "cAdvisor:      http://localhost:8080"
echo "Elasticsearch: http://localhost:9200"
echo ""

echo "✅ Verification complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Open Grafana and add Elasticsearch data source"
echo "  2. Create dashboards using the provided queries"
echo "  3. Update alertmanager.yml with your email settings"
echo "  4. Test alerts by running: yes > /dev/null &"
echo "  5. Kill test with: killall yes"
echo ""
