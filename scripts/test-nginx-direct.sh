#!/bin/bash

echo "=== Testing Nginx Configuration Directly ==="
echo ""

# Get the pod name
API_POD=$(kubectl get pod -n netdata -l app=netdata-minimal-api -o jsonpath='{.items[0].metadata.name}')

echo "1. Testing nginx config syntax:"
kubectl exec -n netdata $API_POD -- nginx -t
echo ""

echo "2. Checking if nginx is actually reading the config:"
kubectl exec -n netdata $API_POD -- ls -la /etc/nginx/conf.d/
echo ""

echo "3. Testing direct curl from inside the pod to Netdata:"
echo "Testing system.cpu chart:"
kubectl exec -n netdata $API_POD -- curl -s "http://netdata:19999/api/v1/data?chart=system.cpu&after=-60&format=json" | head -c 200
echo ""
echo ""

echo "4. Checking available system charts in Netdata:"
kubectl exec -n netdata $API_POD -- curl -s "http://netdata:19999/api/v1/charts" | jq -r '.charts | keys[] | select(startswith("system."))'
echo ""

echo "5. Testing the actual nginx locations:"
kubectl port-forward -n netdata pod/$API_POD 8080:8080 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

# Test with exact paths
echo "Testing exact locations:"
for path in "/" "/cpu" "/memory" "/load" "/uptime" "/nodes" "/health"; do
    response=$(curl -s -w "\n%{http_code}" http://localhost:8080$path 2>/dev/null | tail -1)
    echo "  $path -> HTTP $response"
done

kill $PF_PID 2>/dev/null