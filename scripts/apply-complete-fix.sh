#!/bin/bash

echo "=== Applying Complete Fix for Netdata Minimal API ==="
echo ""

# First test what nginx is doing
chmod +x test-nginx-direct.sh
./test-nginx-direct.sh

echo ""
echo "=== Applying Fixed Configuration ==="
echo ""

# Apply the fixed configuration
echo "1. Applying fixed ConfigMap and Deployment..."
kubectl apply -f fixed-nginx-config.yaml

# Wait for rollout
echo ""
echo "2. Waiting for deployment to be ready..."
kubectl rollout status deployment netdata-minimal-api -n netdata --timeout=60s

# Give nginx time to start
sleep 5

# Test the endpoints
echo ""
echo "3. Testing all endpoints after fix:"
kubectl port-forward -n netdata svc/netdata-minimal-api 8080:8080 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test each endpoint
endpoints=("/" "/health" "/cpu" "/memory" "/load" "/uptime" "/nodes")
all_working=true

for endpoint in "${endpoints[@]}"; do
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080$endpoint)
    if [ "$response" = "200" ]; then
        echo -e "  ${GREEN}✓${NC} $endpoint -> HTTP $response"
    else
        echo -e "  ${RED}✗${NC} $endpoint -> HTTP $response"
        all_working=false
    fi
done

echo ""
echo "4. Sample data test:"
echo ""
echo "CPU Data (showing idle percentage):"
curl -s http://localhost:8080/cpu 2>/dev/null | jq '.data[0][8]' 2>/dev/null && echo "(This is CPU idle %)"

echo ""
echo "Memory Data (showing used/free):"
curl -s http://localhost:8080/memory 2>/dev/null | jq '.data[0][1:3]' 2>/dev/null && echo "[used, free] in MB"

kill $PF_PID 2>/dev/null

if [ "$all_working" = true ]; then
    echo ""
    echo -e "${GREEN}=== ✓ All endpoints are working! ===${NC}"
    echo ""
    echo "Your minimal metrics API is now available at:"
    echo "  Internal: http://netdata-minimal-api.netdata.svc.cluster.local:8080"
    echo "  External: http://api.catdevops.net"
    echo ""
    echo "Test externally with:"
    echo "  curl http://api.catdevops.net/cpu"
    echo "  curl http://api.catdevops.net/memory"
else
    echo ""
    echo -e "${RED}=== Some endpoints are still not working ===${NC}"
    echo "Checking nginx logs for errors..."
    kubectl logs -n netdata -l app=netdata-minimal-api --tail=10
fi