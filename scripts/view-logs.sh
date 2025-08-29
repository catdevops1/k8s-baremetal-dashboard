#!/bin/bash
echo "📋 CatDevOps Application Logs"
echo "============================"
echo ""

if [[ "$1" == "follow" || "$1" == "-f" ]]; then
    echo "📡 Following logs for showcase-website (press Ctrl+C to exit)..."
    kubectl logs -l app=showcase-website -f --tail=50
else
    echo "📜 Recent logs for showcase-website:"
    kubectl logs -l app=showcase-website --tail=50
    echo ""
    echo "💡 Use './scripts/view-logs.sh follow' to stream logs in real-time"
fi
