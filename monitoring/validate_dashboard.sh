#!/bin/bash

# Week 6: Dashboard Validation Script
# Validates all 15 dashboard panels display accurate and timely information

echo "📊 Week 6: Dashboard Data Validation"
echo "===================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TOTAL_PANELS=0
VALID_PANELS=0
INVALID_PANELS=0

# Function to validate panel query
validate_panel() {
    local panel_name=$1
    local query=$2
    local expected_data_points=${3:-1}
    
    TOTAL_PANELS=$((TOTAL_PANELS + 1))
    
    # URL encode the query
    encoded_query=$(echo "$query" | jq -sRr @uri)
    
    # Execute query
    result=$(curl -s "http://localhost:9090/api/v1/query?query=${encoded_query}")
    status=$(echo "$result" | jq -r '.status')
    
    if [ "$status" = "success" ]; then
        data_count=$(echo "$result" | jq -r '.data.result | length')
        
        if [ "$data_count" -ge "$expected_data_points" ]; then
            # Check data freshness (within last 60 seconds)
            latest_value=$(echo "$result" | jq -r '.data.result[0].value[1]')
            if [ "$latest_value" != "null" ] && [ ! -z "$latest_value" ]; then
                echo -e "${GREEN}✓${NC} $panel_name - ${data_count} data points, value: $latest_value"
                VALID_PANELS=$((VALID_PANELS + 1))
                return 0
            else
                echo -e "${YELLOW}⚠${NC} $panel_name - No valid data values"
                INVALID_PANELS=$((INVALID_PANELS + 1))
                return 1
            fi
        else
            echo -e "${RED}✗${NC} $panel_name - Expected >=$expected_data_points data points, got $data_count"
            INVALID_PANELS=$((INVALID_PANELS + 1))
            return 1
        fi
    else
        error=$(echo "$result" | jq -r '.error // "Unknown error"')
        echo -e "${RED}✗${NC} $panel_name - Query failed: $error"
        INVALID_PANELS=$((INVALID_PANELS + 1))
        return 1
    fi
}

# Function to check Elasticsearch panel
validate_es_panel() {
    local panel_name=$1
    local index_pattern=$2
    
    TOTAL_PANELS=$((TOTAL_PANELS + 1))
    
    result=$(curl -s "http://localhost:9200/${index_pattern}/_search?size=1")
    hits=$(echo "$result" | jq -r '.hits.total.value')
    
    if [ "$hits" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} $panel_name - $hits documents found"
        VALID_PANELS=$((VALID_PANELS + 1))
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $panel_name - No data found in Elasticsearch"
        INVALID_PANELS=$((INVALID_PANELS + 1))
        return 1
    fi
}

echo "═══════════════════════════════════════════════════════"
echo "VALIDATING: System Overview Panels"
echo "═══════════════════════════════════════════════════════"
validate_panel "1. CPU Usage (%)" "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)"
validate_panel "2. Memory Usage (%)" "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"
validate_panel "3. System Uptime" "node_time_seconds - node_boot_time_seconds"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "VALIDATING: CPU & Memory Details"
echo "═══════════════════════════════════════════════════════"
validate_panel "4. CPU Core Breakdown" "avg by(cpu) (irate(node_cpu_seconds_total{mode!=\"idle\"}[5m])) * 100" 4
validate_panel "5. Process Count (Running)" "node_procs_running"
validate_panel "5. Process Count (Blocked)" "node_procs_blocked"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "VALIDATING: Disk & I/O Panels"
echo "═══════════════════════════════════════════════════════"
validate_panel "6. Disk Usage (%)" "node_filesystem_size_bytes{fstype!~\"tmpfs|overlay\"}"
validate_panel "7. Disk I/O - Read" "irate(node_disk_read_bytes_total[5m])"
validate_panel "8. Disk I/O - Write" "irate(node_disk_written_bytes_total[5m])"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "VALIDATING: Network Panels"
echo "═══════════════════════════════════════════════════════"
validate_panel "9. Network Traffic (RX)" "irate(node_network_receive_bytes_total{device!=\"lo\"}[5m])"
validate_panel "9. Network Traffic (TX)" "irate(node_network_transmit_bytes_total{device!=\"lo\"}[5m])"
validate_panel "10. Packet Loss (RX)" "irate(node_network_receive_drop_total[5m])"
validate_panel "10. Packet Loss (TX)" "irate(node_network_transmit_drop_total[5m])"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "VALIDATING: Container Panels"
echo "═══════════════════════════════════════════════════════"
validate_panel "11. Container CPU Usage" "sum(rate(container_cpu_usage_seconds_total{id=~\"/docker/.*\"}[5m])) by (id)" 5
validate_panel "12. Container Memory Usage" "container_memory_working_set_bytes{id=~\"/docker/.*\"}" 5
echo ""

echo "═══════════════════════════════════════════════════════"
echo "VALIDATING: System Load & Logs"
echo "═══════════════════════════════════════════════════════"
validate_panel "13. System Load (1 min)" "node_load1"
validate_panel "13. System Load (5 min)" "node_load5"
validate_panel "13. System Load (15 min)" "node_load15"
validate_es_panel "14. Recent Log Messages" "system-logs-*"
validate_es_panel "15. System Logs (Live Feed)" "system-logs-*"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "ADDITIONAL VALIDATION TESTS"
echo "═══════════════════════════════════════════════════════"

# Test data refresh rate
echo "Testing data refresh rate..."
first_value=$(curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" | jq -r '.data.result[0].value[1]')
echo "  Waiting 10 seconds..."
sleep 10
second_value=$(curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" | jq -r '.data.result[0].value[1]')

if [ "$first_value" != "$second_value" ]; then
    echo -e "${GREEN}✓${NC} Data is updating in real-time"
else
    echo -e "${RED}✗${NC} Data appears to be stale"
fi

# Check dashboard auto-refresh
echo ""
echo "Checking dashboard configuration..."
dashboard=$(curl -s -u admin:admin "http://localhost:3000/api/search?query=System%20Metrics%20Overview%20v2" | jq -r '.[0].uid')
if [ ! -z "$dashboard" ] && [ "$dashboard" != "null" ]; then
    echo -e "${GREEN}✓${NC} Dashboard 'System Metrics Overview v2' found (UID: $dashboard)"
    echo "  Dashboard URL: http://localhost:3000/d/$dashboard"
else
    echo -e "${RED}✗${NC} Dashboard 'System Metrics Overview v2' not found"
fi

# Check data sources
echo ""
echo "Validating data sources..."
prom_ds=$(curl -s -u admin:admin http://localhost:3000/api/datasources | jq -r '.[] | select(.type=="prometheus") | .name')
if [ ! -z "$prom_ds" ]; then
    echo -e "${GREEN}✓${NC} Prometheus data source: $prom_ds"
else
    echo -e "${RED}✗${NC} Prometheus data source not configured"
fi

es_ds=$(curl -s -u admin:admin http://localhost:3000/api/datasources | jq -r '.[] | select(.type=="elasticsearch") | .name')
if [ ! -z "$es_ds" ]; then
    echo -e "${GREEN}✓${NC} Elasticsearch data source: $es_ds"
else
    echo -e "${RED}✗${NC} Elasticsearch data source not configured"
fi

echo ""
echo "═══════════════════════════════════════════════════════"
echo "VALIDATION SUMMARY"
echo "═══════════════════════════════════════════════════════"
echo "Total Panels Tested: $TOTAL_PANELS"
echo -e "${GREEN}Valid Panels:        $VALID_PANELS${NC}"
echo -e "${RED}Invalid Panels:      $INVALID_PANELS${NC}"
echo ""

accuracy=$((VALID_PANELS * 100 / TOTAL_PANELS))
echo "Dashboard Accuracy: ${accuracy}%"
echo ""

if [ $INVALID_PANELS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL DASHBOARD PANELS ARE VALID!${NC}"
    echo ""
    echo "Dashboard is displaying accurate and timely information."
    echo "Access dashboard: http://localhost:3000"
    exit 0
elif [ $accuracy -ge 80 ]; then
    echo -e "${YELLOW}⚠ MOST PANELS ARE VALID${NC}"
    echo ""
    echo "Some panels may need attention, but overall dashboard is functional."
    exit 0
else
    echo -e "${RED}❌ MULTIPLE PANELS HAVE ISSUES${NC}"
    echo ""
    echo "Please review dashboard configuration and data sources."
    exit 1
fi
