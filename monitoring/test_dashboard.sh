#!/bin/bash

echo "🧪 Testing Grafana Dashboard - System Metrics Overview"
echo "================================================"
echo ""

# Check if dashboard is accessible
echo "1️⃣ Checking dashboard accessibility..."
DASHBOARD_CHECK=$(curl -s -u admin:admin 'http://localhost:3000/api/search?query=System' | jq -r '.[0].title')
if [ "$DASHBOARD_CHECK" == "System Metrics Overview" ]; then
    echo "   ✅ Dashboard found: $DASHBOARD_CHECK"
    DASHBOARD_URL=$(curl -s -u admin:admin 'http://localhost:3000/api/search?query=System' | jq -r '.[0].url')
    echo "   📊 Access at: http://localhost:3000$DASHBOARD_URL"
else
    echo "   ❌ Dashboard not found"
    exit 1
fi

echo ""
echo "2️⃣ Checking data sources..."
PROM_CHECK=$(curl -s -u admin:admin http://localhost:3000/api/datasources | jq -r '.[] | select(.type=="prometheus") | .name')
ES_CHECK=$(curl -s -u admin:admin http://localhost:3000/api/datasources | jq -r '.[] | select(.type=="elasticsearch") | .name')

if [ ! -z "$PROM_CHECK" ]; then
    echo "   ✅ Prometheus data source configured"
else
    echo "   ❌ Prometheus data source missing"
fi

if [ ! -z "$ES_CHECK" ]; then
    echo "   ✅ Elasticsearch data source configured"
else
    echo "   ❌ Elasticsearch data source missing"
fi

echo ""
echo "3️⃣ Testing metrics availability..."
# Test CPU metric
CPU_METRIC=$(curl -s 'http://localhost:9090/api/v1/query?query=node_cpu_seconds_total' | jq -r '.status')
if [ "$CPU_METRIC" == "success" ]; then
    echo "   ✅ CPU metrics available"
else
    echo "   ❌ CPU metrics unavailable"
fi

# Test Memory metric
MEM_METRIC=$(curl -s 'http://localhost:9090/api/v1/query?query=node_memory_MemAvailable_bytes' | jq -r '.status')
if [ "$MEM_METRIC" == "success" ]; then
    echo "   ✅ Memory metrics available"
else
    echo "   ❌ Memory metrics unavailable"
fi

# Test Network metric
NET_METRIC=$(curl -s 'http://localhost:9090/api/v1/query?query=node_network_receive_bytes_total' | jq -r '.status')
if [ "$NET_METRIC" == "success" ]; then
    echo "   ✅ Network metrics available"
else
    echo "   ❌ Network metrics unavailable"
fi

echo ""
echo "4️⃣ Testing logs availability..."
LOG_CHECK=$(curl -s 'http://localhost:9200/system-logs-*/_search?size=1' | jq -r '.hits.total.value')
if [ "$LOG_CHECK" -gt 0 ]; then
    echo "   ✅ Logs available in Elasticsearch ($LOG_CHECK documents)"
else
    echo "   ⚠️  No logs found yet (this is normal if just started)"
fi

echo ""
echo "================================================"
echo "✅ Week 4 Dashboard Test Complete!"
echo ""
echo "🌐 Open Grafana: http://localhost:3000"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "📊 The 'System Metrics Overview' dashboard should load automatically"
echo ""
echo "🧪 To test dynamic updates:"
echo "   - Run CPU stress: yes > /dev/null &"
echo "   - Generate logs: ./generate_logs.sh"
echo "   - Watch the dashboard update in real-time!"
echo ""
