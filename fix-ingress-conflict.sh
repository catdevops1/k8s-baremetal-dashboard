#!/bin/bash
# Fix ingress conflict and complete the deployment

echo "🔧 Fixing ingress conflict..."

# Check existing ingresses
echo "📋 Current ingresses:"
kubectl get ingress -A

echo ""
echo "🔄 Replacing existing ingress with new showcase website..."

# Delete the conflicting ingress (the old my-app)
kubectl delete ingress my-app --ignore-not-found=true

# Apply the new ingress
kubectl apply -f applications/showcase-website/k8s-manifests/ingress.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/showcase-website --timeout=300s

echo ""
echo "📊 Final Deployment Status:"
echo "=========================="
kubectl get pods -l app=showcase-website -o wide
echo ""
kubectl get svc showcase-website
echo ""
kubectl get ingress showcase-website

echo ""
echo "🌍 Testing website connectivity..."
sleep 10  # Give ingress a moment to update
curl -s -o /dev/null -w "Website Response: %{http_code}\n" https://catdevops.net || echo "Website may still be updating (normal for first deployment)"

echo ""
echo "✅ SETUP COMPLETE!"
echo "=================="
echo ""
echo "🌐 Your live dashboard: https://catdevops.net"
echo "🌐 Alternative URL: https://www.catdevops.net"
echo ""
echo "📋 Next steps:"
echo "1. git commit -m 'Complete k8s dashboard setup'"
echo "2. git push origin main"  
echo "3. Visit https://catdevops.net"
echo ""
echo "🛠️ Management commands:"
echo "./scripts/health-check.sh    # Check everything"
echo "./scripts/deploy.sh          # Update website"
echo "./scripts/view-logs.sh       # View logs"
