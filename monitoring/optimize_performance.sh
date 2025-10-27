#!/bin/bash

# Week 6: Performance Optimization Script
# Analyzes and optimizes data processing performance

echo "⚡ Week 6: Performance Optimization Analysis"
echo "============================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "📊 1. Analyzing Prometheus Performance"
echo "--------------------------------------"

# Check Prometheus storage size
prom_storage=$(docker exec prometheus du -sh /prometheus 2>/dev/null | awk '{print $1}')
echo "Prometheus storage size: $prom_storage"

# Check number of time series
time_series=$(curl -s http://localhost:9090/api/v1/status/tsdb | jq -r '.data.numSeries')
echo "Active time series: $time_series"

# Check query performance
echo ""
echo "Testing query performance (10 queries):"
total_time=0
for i in {1..10}; do
    start=$(date +%s%N)
    curl -s "http://localhost:9090/api/v1/query?query=node_cpu_seconds_total" > /dev/null
    end=$(date +%s%N)
    query_time=$(( (end - start) / 1000000 ))
    total_time=$((total_time + query_time))
done
avg_time=$((total_time / 10))
echo "  Average query time: ${avg_time}ms"

if [ $avg_time -lt 100 ]; then
    echo -e "  ${GREEN}✓ Excellent performance${NC}"
elif [ $avg_time -lt 500 ]; then
    echo -e "  ${YELLOW}⚠ Acceptable performance${NC}"
else
    echo -e "  ${RED}✗ Slow queries detected${NC}"
fi

echo ""
echo "📊 2. Analyzing Elasticsearch Performance"
echo "-----------------------------------------"

# Check Elasticsearch cluster health
es_health=$(curl -s http://localhost:9200/_cluster/health)
es_status=$(echo "$es_health" | jq -r '.status')
active_shards=$(echo "$es_health" | jq -r '.active_shards')
unassigned_shards=$(echo "$es_health" | jq -r '.unassigned_shards')

echo "Cluster status: $es_status"
echo "Active shards: $active_shards"
echo "Unassigned shards: $unassigned_shards"

# Check index sizes
echo ""
echo "Index sizes:"
curl -s "http://localhost:9200/_cat/indices/system-logs-*?h=index,store.size&s=index:desc" | head -5

# Check Elasticsearch query performance
echo ""
echo "Testing Elasticsearch query performance (10 queries):"
es_total_time=0
for i in {1..10}; do
    start=$(date +%s%N)
    curl -s "http://localhost:9200/system-logs-*/_search?size=10" > /dev/null
    end=$(date +%s%N)
    es_query_time=$(( (end - start) / 1000000 ))
    es_total_time=$((es_total_time + es_query_time))
done
es_avg_time=$((es_total_time / 10))
echo "  Average query time: ${es_avg_time}ms"

if [ $es_avg_time -lt 100 ]; then
    echo -e "  ${GREEN}✓ Excellent performance${NC}"
elif [ $es_avg_time -lt 500 ]; then
    echo -e "  ${YELLOW}⚠ Acceptable performance${NC}"
else
    echo -e "  ${RED}✗ Slow queries detected${NC}"
fi

echo ""
echo "📊 3. Analyzing Docker Resource Usage"
echo "-------------------------------------"
echo ""
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"

echo ""
echo "📊 4. Performance Recommendations"
echo "----------------------------------"

# Check for high resource usage
high_cpu=$(docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}" | awk '{gsub(/%/, "", $2); if ($2 > 50) print $1}')
high_mem=$(docker stats --no-stream --format "{{.Name}} {{.MemPerc}}" | awk '{gsub(/%/, "", $2); if ($2 > 70) print $1}')

if [ ! -z "$high_cpu" ]; then
    echo -e "${YELLOW}⚠ High CPU usage detected:${NC}"
    echo "$high_cpu" | while read -r container; do
        echo "  - $container"
    done
    echo ""
    echo "Recommendations:"
    echo "  1. Increase scrape_interval in prometheus.yml (currently 10s)"
    echo "  2. Reduce dashboard auto-refresh rate"
    echo "  3. Limit time-series retention"
fi

if [ ! -z "$high_mem" ]; then
    echo -e "${YELLOW}⚠ High memory usage detected:${NC}"
    echo "$high_mem" | while read -r container; do
        echo "  - $container"
    done
    echo ""
    echo "Recommendations:"
    echo "  1. Increase Elasticsearch heap size in docker-compose.yml"
    echo "  2. Reduce log retention period"
    echo "  3. Enable log index lifecycle management"
fi

# Check time series count
if [ "$time_series" -gt 10000 ]; then
    echo -e "${YELLOW}⚠ High number of time series: $time_series${NC}"
    echo "Recommendations:"
    echo "  1. Review metric relabeling in prometheus.yml"
    echo "  2. Drop unnecessary metrics"
    echo "  3. Increase storage capacity"
fi

# Check query performance
if [ $avg_time -gt 500 ]; then
    echo -e "${RED}✗ Slow Prometheus queries detected${NC}"
    echo "Recommendations:"
    echo "  1. Optimize dashboard queries (use recording rules)"
    echo "  2. Reduce query range (shorter time windows)"
    echo "  3. Add more resources to Prometheus container"
fi

if [ $es_avg_time -gt 500 ]; then
    echo -e "${RED}✗ Slow Elasticsearch queries detected${NC}"
    echo "Recommendations:"
    echo "  1. Add index templates with optimized mappings"
    echo "  2. Reduce log verbosity in applications"
    echo "  3. Implement log sampling for high-volume logs"
fi

# Check log indices age
old_indices=$(curl -s "http://localhost:9200/_cat/indices/system-logs-*?h=index&s=index:asc" | wc -l | tr -d ' ')
if [ "$old_indices" -gt 7 ]; then
    echo -e "${YELLOW}⚠ Found $old_indices log indices${NC}"
    echo "Recommendations:"
    echo "  1. Implement index lifecycle management (ILM)"
    echo "  2. Set up automatic index deletion after 7 days"
    echo "  3. Use index rollover for better performance"
fi

echo ""
echo "📊 5. Optimization Summary"
echo "--------------------------"
echo ""
echo "Current Performance Metrics:"
echo "  • Prometheus avg query time: ${avg_time}ms"
echo "  • Elasticsearch avg query time: ${es_avg_time}ms"
echo "  • Active time series: $time_series"
echo "  • Elasticsearch status: $es_status"
echo "  • Log indices: $old_indices"
echo ""

# Calculate performance score
score=100
if [ $avg_time -gt 100 ]; then score=$((score - 10)); fi
if [ $avg_time -gt 500 ]; then score=$((score - 20)); fi
if [ $es_avg_time -gt 100 ]; then score=$((score - 10)); fi
if [ $es_avg_time -gt 500 ]; then score=$((score - 20)); fi
if [ "$es_status" != "green" ]; then score=$((score - 10)); fi
if [ ! -z "$high_cpu" ]; then score=$((score - 10)); fi
if [ ! -z "$high_mem" ]; then score=$((score - 10)); fi

echo "Overall Performance Score: $score/100"
echo ""

if [ $score -ge 80 ]; then
    echo -e "${GREEN}✅ System performance is EXCELLENT${NC}"
elif [ $score -ge 60 ]; then
    echo -e "${YELLOW}⚠ System performance is ACCEPTABLE${NC}"
    echo "Consider implementing recommended optimizations"
else
    echo -e "${RED}✗ System performance needs IMPROVEMENT${NC}"
    echo "Please review and implement recommended optimizations"
fi

echo ""
echo "💡 Quick Optimization Commands:"
echo "-------------------------------"
echo ""
echo "# Restart services to free resources:"
echo "docker compose restart"
echo ""
echo "# Clean old Elasticsearch indices (>7 days):"
echo "curl -X DELETE 'http://localhost:9200/system-logs-$(date -v-8d +%Y.%m.%d)'"
echo ""
echo "# Check Prometheus metrics cardinality:"
echo "curl -s 'http://localhost:9090/api/v1/status/tsdb' | jq '.data'"
echo ""
echo "# Optimize Elasticsearch indices:"
echo "curl -X POST 'http://localhost:9200/system-logs-*/_forcemerge?max_num_segments=1'"
echo ""
