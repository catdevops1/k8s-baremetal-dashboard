#!/bin/bash
echo "🔄 Updating showcase website content..."

# Recreate ConfigMap with latest content
kubectl create configmap showcase-website-content \
    --from-file=index.html=applications/showcase-website/frontend/src/index.html \
    --dry-run=client -o yaml | kubectl apply -f -

# Restart deployment to pick up new content
kubectl rollout restart deployment/showcase-website

# Wait for rollout
kubectl rollout status deployment/showcase-website

echo "✅ Website content updated successfully!"
