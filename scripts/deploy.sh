#!/bin/bash
echo "🚀 Deploying CatDevOps Showcase Website..."

# Apply all manifests
echo "📦 Applying Kubernetes manifests..."
kubectl apply -f applications/showcase-website/k8s-manifests/

# Wait for rollout
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/showcase-website --timeout=300s

# Display status
echo ""
echo "📊 Deployment Status:"
echo "===================="
kubectl get pods -l app=showcase-website -o wide
echo ""
kubectl get svc showcase-website
echo ""
kubectl get ingress showcase-website

echo ""
echo "✅ Deployment completed successfully!"
echo ""
echo "🌐 Your website should be available at:"
echo "   https://catdevops.net"
echo "   https://www.catdevops.net"
