#!/bin/bash

# Sample Log Generator for Testing
# Generates various log entries to test the pipeline

LOG_FILE="sample_app.log"

echo "🔄 Generating sample logs for testing..."
echo "Log file: $LOG_FILE"
echo ""

# Function to generate random log levels
get_random_level() {
    levels=("INFO" "WARN" "ERROR" "DEBUG")
    echo ${levels[$RANDOM % ${#levels[@]}]}
}

# Function to generate sample messages
get_random_message() {
    messages=(
        "User authentication successful"
        "Database connection established"
        "Cache miss for key user_123"
        "API request processed in 45ms"
        "Memory usage at 65%"
        "Background job completed"
        "Failed to connect to external service"
        "Rate limit exceeded for IP 192.168.1.100"
        "File upload completed successfully"
        "Session expired for user"
    )
    echo ${messages[$RANDOM % ${#messages[@]}]}
}

# Generate initial batch of logs
echo "Generating 10 sample log entries..."
for i in {1..10}; do
    level=$(get_random_level)
    message=$(get_random_message)
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$timestamp $level $message" >> $LOG_FILE
    echo "  [$i] $timestamp $level $message"
    sleep 0.5
done

echo ""
echo "✅ Sample logs generated!"
echo ""
echo "To verify logs reached Elasticsearch:"
echo "  curl 'http://localhost:9200/system-logs-*/_search?pretty&size=5'"
echo ""
echo "To continuously generate logs:"
echo "  watch -n 2 'echo \"\$(date) INFO Test message\" >> sample_app.log'"
echo ""
