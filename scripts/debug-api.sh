#!/bin/bash

echo "=== Debugging Netdata Minimal API ==="
echo ""

# Check the ConfigMap
echo "1. Checking ConfigMap content:"
kubectl get configmap minimal-api-nginx-config -n netdata -o yaml | grep -A 50 "default.conf:"
echo ""

# Check if the pod is using the ConfigMap
echo "2. Checking pod configuration:"
kubectl describe pod -n netdata -l app=netdata-minimal-api | grep -A 10 "Mounts:"
echo ""

# Check nginx error logs
echo "3. Checking nginx logs:"
kubectl logs -n netdata -l app=netdata-minimal-api --tail=20
echo ""

# Test if Netdata parent is accessible from the API pod
echo "4. Testing Netdata connectivity from API pod:"
API_POD=$(kubectl get pod -n netdata -l app=netdata-minimal-api -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n netdata $API_POD -- wget -O- -q "http://netdata:19999/api/v1/info" | head -5
echo ""

# Check what's actually running in the nginx container
echo "5. Checking nginx configuration inside container:"
kubectl exec -n netdata $API_POD -- cat /etc/nginx/conf.d/default.conf 2>/dev/null | head -20
echo ""

# Test direct access to Netdata charts
echo "6. Testing direct Netdata API access:"
kubectl port-forward -n netdata svc/netdata 19999:19999 > /dev/null 2>&1 &
PF_PID=$!
sleep 3

echo "Available system charts:"
curl -s http://localhost:19999/api/v1/charts | jq -r '.charts | keys[] | select(startswith("system."))'

kill $PF_PID 2>/dev/null