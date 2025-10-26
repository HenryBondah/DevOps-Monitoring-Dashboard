#!/bin/bash

echo "🧪 Week 5: Alert Testing Script"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display menu
show_menu() {
    echo "Select a test to run:"
    echo "1) Test CPU Alert (High CPU Usage)"
    echo "2) Test Memory Alert (High Memory Usage)"
    echo "3) Test Load Alert (High System Load)"
    echo "4) Test All Alerts"
    echo "5) Check Current Alerts"
    echo "6) Exit"
    echo ""
}

# Function to trigger CPU stress
test_cpu_alert() {
    echo -e "${YELLOW}🔥 Triggering CPU stress test...${NC}"
    echo "This will spike CPU for 3 minutes to trigger the alert."
    echo ""
    
    # Use 'yes' command to create CPU load (available on all Unix systems)
    echo "Starting CPU stress on 2 cores..."
    yes > /dev/null & PID1=$!
    yes > /dev/null & PID2=$!
    
    echo -e "${GREEN}✅ CPU stress started (PIDs: $PID1, $PID2)${NC}"
    echo ""
    echo "Monitor your Grafana dashboard: http://localhost:3000"
    echo "Alert should trigger in ~2 minutes if CPU > 80%"
    echo ""
    echo "Press ENTER to stop the stress test..."
    read
    
    kill $PID1 $PID2 2>/dev/null
    echo -e "${GREEN}✅ CPU stress stopped${NC}"
}

# Function to trigger memory stress
test_memory_alert() {
    echo -e "${YELLOW}🔥 Triggering Memory stress test...${NC}"
    echo "This will allocate memory to trigger the alert."
    echo ""
    
    # Create a large array in memory
    echo "Allocating memory..."
    stress_memory() {
        local arr=()
        for i in {1..1000000}; do
            arr+=("$i: This is a test string to consume memory")
        done
        sleep 300
    }
    
    stress_memory &
    MEM_PID=$!
    
    echo -e "${GREEN}✅ Memory stress started (PID: $MEM_PID)${NC}"
    echo ""
    echo "Monitor your Grafana dashboard: http://localhost:3000"
    echo "Alert should trigger in ~5 minutes if Memory > 75%"
    echo ""
    echo "Press ENTER to stop the stress test..."
    read
    
    kill $MEM_PID 2>/dev/null
    echo -e "${GREEN}✅ Memory stress stopped${NC}"
}

# Function to trigger load alert
test_load_alert() {
    echo -e "${YELLOW}🔥 Triggering System Load test...${NC}"
    echo "This will create multiple processes to increase system load."
    echo ""
    
    # Create multiple background processes
    for i in {1..8}; do
        (while true; do :; done) &
        PIDS[$i]=$!
    done
    
    echo -e "${GREEN}✅ Load stress started${NC}"
    echo ""
    echo "Monitor your Grafana dashboard: http://localhost:3000"
    echo "Alert should trigger in ~3 minutes if Load > 5"
    echo ""
    echo "Press ENTER to stop the stress test..."
    read
    
    for pid in "${PIDS[@]}"; do
        kill $pid 2>/dev/null
    done
    echo -e "${GREEN}✅ Load stress stopped${NC}"
}

# Function to check current alerts
check_alerts() {
    echo -e "${YELLOW}📊 Checking current Prometheus alerts...${NC}"
    echo ""
    
    ALERTS=$(curl -s http://localhost:9090/api/v1/alerts | jq -r '.data.alerts[] | "\(.labels.alertname): \(.state)"')
    
    if [ -z "$ALERTS" ]; then
        echo -e "${GREEN}✅ No active alerts${NC}"
    else
        echo -e "${RED}Active Alerts:${NC}"
        echo "$ALERTS"
    fi
    
    echo ""
    echo "View all alerts: http://localhost:9090/alerts"
    echo "Alertmanager: http://localhost:9093"
    echo "Grafana Alerting: http://localhost:3000/alerting/list"
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [1-6]: " choice
    echo ""
    
    case $choice in
        1)
            test_cpu_alert
            ;;
        2)
            test_memory_alert
            ;;
        3)
            test_load_alert
            ;;
        4)
            echo "Starting all tests sequentially..."
            test_cpu_alert
            sleep 5
            test_memory_alert
            sleep 5
            test_load_alert
            ;;
        5)
            check_alerts
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    
    echo ""
    echo "================================"
    echo ""
done
