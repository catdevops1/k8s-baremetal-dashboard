#!/bin/bash
echo "🏥 CatDevOps Cluster Health Check"
echo "=================================="
echo ""

# Check cluster connectivity
echo "🔌 Cluster Connectivity:"
if kubectl cluster-info &>/dev/null; then
    echo "   ✅ Connected to cluster"
else
    echo "   ❌ Cannot connect to cluster"
    exit 1
fi

echo ""
echo "🖥️  Node Status:"
kubectl get nodes -o custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,VERSION:.status.nodeInfo.kubeletVersion

echo ""
echo "🚀 Application Status:"
kubectl get pods -l app=showcase-website -o wide

echo ""
echo "🌐 Service Status:"
kubectl get svc showcase-website

echo ""
echo "🔗 Ingress Status:"
kubectl get ingress showcase-website

echo ""
echo "🌍 Website Health Check:"
if curl -s -o /dev/null -w "%{http_code}" https://catdevops.net | grep -qE "200|301|302"; then
    echo "   ✅ Website is accessible ($(curl -s -o /dev/null -w "%{http_code}" https://catdevops.net))"
else
    echo "   ⚠️  Website check failed or DNS still propagating"
fi

echo ""
echo "🏥 Health check completed!"
