#!/bin/bash

echo "=== Verifying Netdata Minimal Metrics API ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check pod status
echo -e "${BLUE}1. Checking API pod status:${NC}"
kubectl get pods -n netdata -l app=netdata-minimal-api
echo ""

# Check service
echo -e "${BLUE}2. Checking service:${NC}"
kubectl get svc netdata-minimal-api -n netdata
echo ""

# Check ingress
echo -e "${BLUE}3. Checking ingress configuration:${NC}"
kubectl get ingress netdata-api -n netdata
echo ""

# Test internal connectivity
echo -e "${BLUE}4. Testing internal connectivity:${NC}"
echo "Setting up port forwarding..."
kubectl port-forward -n netdata svc/netdata-minimal-api 8080:8080 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

# Test each endpoint locally
echo -e "${GREEN}Testing local endpoints:${NC}"
endpoints=("/health" "/cpu" "/memory" "/load" "/uptime" "/nodes")
for endpoint in "${endpoints[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080$endpoint)
    if [ "$response" = "200" ]; then
        echo -e "  ✓ http://localhost:8080$endpoint - ${GREEN}OK${NC} (200)"
    else
        echo -e "  ✗ http://localhost:8080$endpoint - ${RED}Failed${NC} ($response)"
    fi
done
echo ""

# Kill port forward
kill $PF_PID 2>/dev/null

# Test external connectivity if available
echo -e "${BLUE}5. Testing external connectivity (api.catdevops.net):${NC}"
external_response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://api.catdevops.net/health 2>/dev/null)
if [ "$external_response" = "200" ]; then
    echo -e "${GREEN}✓ External API is accessible${NC}"
    echo ""
    echo "Testing external endpoints:"
    for endpoint in "${endpoints[@]}"; do
        response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 http://api.catdevops.net$endpoint)
        if [ "$response" = "200" ]; then
            echo -e "  ✓ http://api.catdevops.net$endpoint - ${GREEN}OK${NC} (200)"
        else
            echo -e "  ✗ http://api.catdevops.net$endpoint - ${YELLOW}Status${NC} ($response)"
        fi
    done
else
    echo -e "${YELLOW}⚠ External API not accessible (status: $external_response)${NC}"
    echo "This could be due to:"
    echo "  - DNS propagation delay"
    echo "  - Cloudflare tunnel not configured for this endpoint"
    echo "  - Firewall/network issues"
fi
echo ""

# Show sample data
echo -e "${BLUE}6. Sample data from API:${NC}"
kubectl port-forward -n netdata svc/netdata-minimal-api 8080:8080 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

echo -e "${GREEN}CPU Metrics:${NC}"
curl -s http://localhost:8080/cpu 2>/dev/null | jq '{
    chart: .id,
    name: .name,
    latest_values: .data[0],
    labels: .labels
}' 2>/dev/null || echo "Unable to parse CPU data"
echo ""

echo -e "${GREEN}Memory Metrics:${NC}"
curl -s http://localhost:8080/memory 2>/dev/null | jq '{
    chart: .id,
    name: .name,
    latest_values: .data[0],
    labels: .labels
}' 2>/dev/null || echo "Unable to parse memory data"
echo ""

# Kill port forward
kill $PF_PID 2>/dev/null

# Show access URLs
echo -e "${BLUE}=== Access Information ===${NC}"
echo ""
echo "Your minimal metrics API is available at:"
echo ""
echo -e "${GREEN}Local access (port forwarding):${NC}"
echo "  kubectl port-forward -n netdata svc/netdata-minimal-api 8080:8080"
echo "  Then visit: http://localhost:8080/<endpoint>"
echo ""
echo -e "${GREEN}External access:${NC}"
echo "  Base URL: http://api.catdevops.net"
echo ""
echo -e "${GREEN}Available endpoints:${NC}"
echo "  /health  - Health check"
echo "  /cpu     - CPU utilization metrics"
echo "  /memory  - Memory usage metrics"
echo "  /load    - System load averages"
echo "  /uptime  - System uptime"
echo "  /nodes   - Node information"
echo "  /metrics - Combined minimal metrics"
echo ""

# Check if k8s-state is still running (should be scaled down)
k8s_state_replicas=$(kubectl get deployment netdata-k8s-state -n netdata -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$k8s_state_replicas" = "0" ] || [ -z "$k8s_state_replicas" ]; then
    echo -e "${GREEN}✓ k8s-state deployment is scaled down (minimal metrics mode)${NC}"
else
    echo -e "${YELLOW}⚠ k8s-state deployment is still running ($k8s_state_replicas replicas)${NC}"
    echo "  Consider scaling it down: kubectl scale deployment netdata-k8s-state -n netdata --replicas=0"
fi