#!/bin/bash

# Week 6: Comprehensive System Testing Script
# Tests all components, validates data accuracy, and checks performance

set -e

echo "🧪 Week 6: DevOps Monitoring Dashboard - System Testing"
echo "========================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Test result tracking
declare -a FAILED_TEST_NAMES

# Function to log test result
log_test() {
    local test_name=$1
    local result=$2
    local message=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$result" = "PASS" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif [ "$result" = "FAIL" ]; then
        echo -e "${RED}✗ FAIL${NC}: $test_name - $message"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TEST_NAMES+=("$test_name: $message")
    elif [ "$result" = "WARN" ]; then
        echo -e "${YELLOW}⚠ WARN${NC}: $test_name - $message"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# Function to check HTTP endpoint
check_endpoint() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response" = "$expected_code" ]; then
        log_test "$name endpoint" "PASS"
        return 0
    else
        log_test "$name endpoint" "FAIL" "Expected $expected_code, got $response"
        return 1
    fi
}

# Function to check Docker container
check_container() {
    local container=$1
    
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null)
        if [ "$status" = "running" ]; then
            log_test "$container container" "PASS"
            return 0
        else
            log_test "$container container" "FAIL" "Status: $status"
            return 1
        fi
    else
        log_test "$container container" "FAIL" "Not found"
        return 1
    fi
}

# Function to check metric availability
check_metric() {
    local metric_name=$1
    local query=$2
    
    result=$(curl -s "http://localhost:9090/api/v1/query?query=$query" | jq -r '.status')
    
    if [ "$result" = "success" ]; then
        data_count=$(curl -s "http://localhost:9090/api/v1/query?query=$query" | jq -r '.data.result | length')
        if [ "$data_count" -gt 0 ]; then
            log_test "$metric_name metric" "PASS"
            return 0
        else
            log_test "$metric_name metric" "WARN" "No data points found"
            return 1
        fi
    else
        log_test "$metric_name metric" "FAIL" "Query failed"
        return 1
    fi
}

# Function to check data freshness
check_data_freshness() {
    local metric=$1
    local max_age_seconds=${2:-60}
    
    timestamp=$(curl -s "http://localhost:9090/api/v1/query?query=$metric" | jq -r '.data.result[0].value[0]')
    current_time=$(date +%s)
    
    if [ ! -z "$timestamp" ] && [ "$timestamp" != "null" ]; then
        age=$((current_time - ${timestamp%.*}))
        if [ $age -le $max_age_seconds ]; then
            log_test "$metric freshness" "PASS"
            return 0
        else
            log_test "$metric freshness" "WARN" "Data is ${age}s old (threshold: ${max_age_seconds}s)"
            return 1
        fi
    else
        log_test "$metric freshness" "FAIL" "No timestamp available"
        return 1
    fi
}

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 1: Docker Container Health"
echo "═══════════════════════════════════════════════════════"
check_container "prometheus"
check_container "alertmanager"
check_container "grafana"
check_container "node-exporter"
check_container "cadvisor"
check_container "elasticsearch"
check_container "logstash"
check_container "filebeat"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 2: Service Endpoints"
echo "═══════════════════════════════════════════════════════"
check_endpoint "Prometheus" "http://localhost:9090/-/healthy"
check_endpoint "Alertmanager" "http://localhost:9093/-/healthy"
check_endpoint "Grafana" "http://localhost:3000/api/health"
check_endpoint "Node Exporter" "http://localhost:9100/metrics"
check_endpoint "cAdvisor" "http://localhost:8080/healthz"
check_endpoint "Elasticsearch" "http://localhost:9200/_cluster/health"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 3: Prometheus Metrics Availability"
echo "═══════════════════════════════════════════════════════"
check_metric "CPU metrics" "node_cpu_seconds_total"
check_metric "Memory metrics" "node_memory_MemTotal_bytes"
check_metric "Disk metrics" "node_filesystem_size_bytes"
check_metric "Network metrics" "node_network_receive_bytes_total"
check_metric "Load metrics" "node_load1"
check_metric "Container CPU metrics" "container_cpu_usage_seconds_total"
check_metric "Container memory metrics" "container_memory_working_set_bytes"
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 4: Data Freshness & Accuracy"
echo "═══════════════════════════════════════════════════════"
check_data_freshness "node_cpu_seconds_total" 30
check_data_freshness "node_memory_MemTotal_bytes" 30
check_data_freshness "container_cpu_usage_seconds_total" 30
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 5: Prometheus Target Status"
echo "═══════════════════════════════════════════════════════"
targets_up=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | select(.health=="up") | .labels.job' | wc -l | tr -d ' ')
targets_total=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets | length')

echo "Active targets: $targets_up / $targets_total"
if [ "$targets_up" -ge 3 ]; then
    log_test "Prometheus targets" "PASS"
else
    log_test "Prometheus targets" "WARN" "Only $targets_up targets are UP"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 6: Alert Rules"
echo "═══════════════════════════════════════════════════════"
rules_loaded=$(curl -s http://localhost:9090/api/v1/rules | jq -r '.data.groups[].rules | length' | awk '{s+=$1} END {print s}')
echo "Alert rules loaded: $rules_loaded"
if [ "$rules_loaded" -ge 9 ]; then
    log_test "Alert rules loaded" "PASS"
else
    log_test "Alert rules loaded" "FAIL" "Expected >= 9, got $rules_loaded"
fi

# Check if any alerts are firing
firing_alerts=$(curl -s http://localhost:9090/api/v1/alerts | jq -r '.data.alerts[] | select(.state=="firing") | .labels.alertname' | wc -l | tr -d ' ')
echo "Currently firing alerts: $firing_alerts"
if [ "$firing_alerts" -eq 0 ]; then
    log_test "System health (no alerts)" "PASS"
else
    log_test "System health" "WARN" "$firing_alerts alert(s) currently firing"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 7: Elasticsearch & Logs"
echo "═══════════════════════════════════════════════════════"
# Check Elasticsearch cluster health
es_status=$(curl -s http://localhost:9200/_cluster/health | jq -r '.status')
echo "Elasticsearch cluster status: $es_status"
if [ "$es_status" = "green" ] || [ "$es_status" = "yellow" ]; then
    log_test "Elasticsearch cluster health" "PASS"
else
    log_test "Elasticsearch cluster health" "FAIL" "Status: $es_status"
fi

# Check if log indices exist
log_indices=$(curl -s "http://localhost:9200/_cat/indices/system-logs-*" | wc -l | tr -d ' ')
echo "Log indices found: $log_indices"
if [ "$log_indices" -gt 0 ]; then
    log_test "Log indices" "PASS"
else
    log_test "Log indices" "WARN" "No log indices found"
fi

# Check log count
log_count=$(curl -s "http://localhost:9200/system-logs-*/_count" 2>/dev/null | jq -r '.count // 0')
echo "Total logs in Elasticsearch: $log_count"
if [ "$log_count" -gt 0 ]; then
    log_test "Log ingestion" "PASS"
else
    log_test "Log ingestion" "WARN" "No logs found in Elasticsearch"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 8: Grafana Data Sources"
echo "═══════════════════════════════════════════════════════"
datasources=$(curl -s -u admin:admin http://localhost:3000/api/datasources 2>/dev/null)
if echo "$datasources" | jq -e '. | type == "array"' > /dev/null 2>&1; then
    prom_ds=$(echo "$datasources" | jq -r '.[] | select(.type=="prometheus") | .name')
    if [ ! -z "$prom_ds" ]; then
        log_test "Prometheus data source" "PASS"
    else
        log_test "Prometheus data source" "FAIL" "Not configured"
    fi

    es_ds=$(echo "$datasources" | jq -r '.[] | select(.type=="elasticsearch") | .name')
    if [ ! -z "$es_ds" ]; then
        log_test "Elasticsearch data source" "PASS"
    else
        log_test "Elasticsearch data source" "FAIL" "Not configured"
    fi
else
    log_test "Grafana API access" "FAIL" "Cannot access datasources API"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 9: Grafana Dashboards"
echo "═══════════════════════════════════════════════════════"
dashboards_result=$(curl -s -u admin:admin http://localhost:3000/api/search 2>/dev/null)
if echo "$dashboards_result" | jq -e '. | type == "array"' > /dev/null 2>&1; then
    dashboards=$(echo "$dashboards_result" | jq -r '.[].title')
    dashboard_count=$(echo "$dashboards" | grep -v '^$' | wc -l | tr -d ' ')
    echo "Dashboards found: $dashboard_count"
    echo "$dashboards" | while read -r dashboard; do
        if [ ! -z "$dashboard" ]; then
            echo "  - $dashboard"
        fi
    done

    if [ "$dashboard_count" -ge 2 ]; then
        log_test "Dashboard provisioning" "PASS"
    else
        log_test "Dashboard provisioning" "WARN" "Expected >= 2 dashboards"
    fi
else
    log_test "Grafana dashboard API" "FAIL" "Cannot access search API"
fi
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUITE 10: Performance Metrics"
echo "═══════════════════════════════════════════════════════"
# Check Prometheus query performance
start_time=$(date +%s%N)
curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" > /dev/null
end_time=$(date +%s%N)
query_time=$(( (end_time - start_time) / 1000000 ))
echo "Prometheus query time: ${query_time}ms"
if [ $query_time -lt 1000 ]; then
    log_test "Prometheus query performance" "PASS"
else
    log_test "Prometheus query performance" "WARN" "Query took ${query_time}ms (>1000ms)"
fi

# Check Elasticsearch query performance
start_time=$(date +%s%N)
curl -s "http://localhost:9200/system-logs-*/_search?size=1" > /dev/null
end_time=$(date +%s%N)
es_query_time=$(( (end_time - start_time) / 1000000 ))
echo "Elasticsearch query time: ${es_query_time}ms"
if [ $es_query_time -lt 1000 ]; then
    log_test "Elasticsearch query performance" "PASS"
else
    log_test "Elasticsearch query performance" "WARN" "Query took ${es_query_time}ms (>1000ms)"
fi

# Check resource usage
echo ""
echo "Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | head -9
echo ""

echo "═══════════════════════════════════════════════════════"
echo "TEST SUMMARY"
echo "═══════════════════════════════════════════════════════"
echo -e "Total Tests:  $TOTAL_TESTS"
echo -e "${GREEN}Passed:       $PASSED_TESTS${NC}"
echo -e "${RED}Failed:       $FAILED_TESTS${NC}"
echo -e "${YELLOW}Warnings:     $WARNINGS${NC}"
echo ""

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "${RED}Failed Tests:${NC}"
    for test in "${FAILED_TEST_NAMES[@]}"; do
        echo "  - $test"
    done
    echo ""
fi

# Overall result
pass_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
echo "Pass Rate: ${pass_rate}%"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CRITICAL TESTS PASSED!${NC}"
    echo ""
    echo "🎉 System is fully operational and validated!"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo "Please review failed tests and fix issues."
    exit 1
fi
