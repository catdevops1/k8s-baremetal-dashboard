#!/bin/bash

echo "=== Testing Netdata Minimal Metrics API ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check pod status
echo -e "${BLUE}Checking API pod status...${NC}"
kubectl get pods -n netdata -l app=netdata-minimal-api
echo ""

# Port forward to test locally
echo -e "${BLUE}Setting up port forwarding...${NC}"
kubectl port-forward -n netdata svc/netdata-minimal-api 8080:8080 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

# Function to test endpoint
test_endpoint() {
    local endpoint=$1
    local description=$2
    echo -e "${GREEN}Testing $description (http://localhost:8080$endpoint)${NC}"
    curl -s http://localhost:8080$endpoint | jq '.' 2>/dev/null | head -20
    if [ $? -eq 0 ]; then
        echo "✓ Success"
    else
        echo "✗ Failed - Raw response:"
        curl -s http://localhost:8080$endpoint | head -20
    fi
    echo ""
}

# Test each endpoint
test_endpoint "/health" "Health Check"
test_endpoint "/cpu" "CPU Metrics"
test_endpoint "/memory" "Memory Metrics"
test_endpoint "/load" "Load Average"
test_endpoint "/uptime" "System Uptime"
test_endpoint "/nodes" "Node Information"
test_endpoint "/metrics" "Combined Metrics"

# Kill port forward
kill $PF_PID 2>/dev/null

echo -e "${BLUE}=== External Access ===${NC}"
echo ""
echo "Your API is available at: http://api.catdevops.net"
echo ""
echo "Available endpoints:"
echo "  • http://api.catdevops.net/cpu     - CPU utilization"
echo "  • http://api.catdevops.net/memory  - Memory usage"
echo "  • http://api.catdevops.net/load    - System load average"
echo "  • http://api.catdevops.net/uptime  - Node uptime"
echo "  • http://api.catdevops.net/nodes   - Node information"
echo "  • http://api.catdevops.net/metrics - All metrics combined"
echo "  • http://api.catdevops.net/health  - Health status"
echo ""

# Check ingress status
echo -e "${BLUE}Ingress Configuration:${NC}"
kubectl get ingress netdata-api -n netdata
echo ""

# Check if external URL is accessible (if you have cloudflare tunnel setup)
echo -e "${BLUE}Testing external access (if available):${NC}"
if command -v curl &> /dev/null; then
    response=$(curl -s -o /dev/null -w "%{http_code}" http://api.catdevops.net/health)
    if [ "$response" = "200" ]; then
        echo "✓ External API is accessible at http://api.catdevops.net"
        echo ""
        echo "Sample CPU metrics from external API:"
        curl -s http://api.catdevops.net/cpu | jq '.labels, .data[0]' 2>/dev/null | head -10
    else
        echo "✗ External API not accessible (HTTP $response) - may need to wait for DNS propagation or check Cloudflare tunnel"
    fi
fi
