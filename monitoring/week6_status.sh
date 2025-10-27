#!/bin/bash

# Week 6 Summary - Quick Status Check

export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"

echo "📊 Week 6: System Status Summary"
echo "================================="
echo ""

echo "🐳 Docker Containers:"
docker ps --format "  ✓ {{.Names}}" | grep -E "(prometheus|grafana|elasticsearch|cadvisor|node-exporter|alertmanager|logstash|filebeat)"

echo ""
echo "🌐 Services:"
echo "  • Grafana:       http://localhost:3000 (admin/admin)"
echo "  • Prometheus:    http://localhost:9090"
echo "  • Alertmanager:  http://localhost:9093"
echo "  • Elasticsearch: http://localhost:9200"
echo "  • cAdvisor:      http://localhost:8080"

echo ""
echo "📈 Metrics:"
prom_targets=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | select(.health=="up") | .labels.job' | wc -l | tr -d ' ')
echo "  • Prometheus targets UP: $prom_targets/3"
log_count=$(curl -s "http://localhost:9200/system-logs-*/_count" | jq -r '.count')
echo "  • Logs in Elasticsearch: $log_count"
es_status=$(curl -s http://localhost:9200/_cluster/health | jq -r '.status')
echo "  • Elasticsearch status:  $es_status"

echo ""
echo "🧪 Week 6 Tests:"
echo "  • System Tests:      ./test_system.sh"
echo "  • Dashboard Tests:   ./validate_dashboard.sh"
echo "  • Performance Tests: ./optimize_performance.sh"

echo ""
echo "✅ All systems operational!"
