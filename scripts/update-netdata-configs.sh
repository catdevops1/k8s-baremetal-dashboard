#!/bin/bash

echo "=== Configuring Netdata for Minimal Metrics (CPU, Memory, Nodes) ==="

# 1. Backup existing ConfigMaps
echo "Backing up existing configurations..."
kubectl get configmap netdata-conf-parent -n netdata -o yaml > netdata-conf-parent-backup.yaml
kubectl get configmap netdata-conf-child -n netdata -o yaml > netdata-conf-child-backup.yaml

# 2. Update parent configuration
echo "Updating parent configuration..."
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: netdata-conf-parent
  namespace: netdata
data:
  netdata.conf: |
    [global]
      update every = 1
      memory mode = ram
      history = 3600
      
    [web]
      bind to = *
      
    [plugins]
      # Enable only essential plugins
      proc = yes
      apps = no
      cgroups = no
      tc = no
      diskspace = no
      go.d = no
      python.d = no
      charts.d = no
      node.d = no
      ebpf = no
      fping = no
      idlejitter = no
      ioping = no
      nfacct = no
      perf = no
      slabinfo = no
      statsd = no
      timex = no
      
    [plugin:proc]
      # Only collect CPU, Memory, Load, and Uptime
      /proc/stat = yes
      /proc/meminfo = yes
      /proc/loadavg = yes
      /proc/uptime = yes
      # Disable everything else
      /proc/vmstat = no
      /proc/net/dev = no
      /proc/diskstats = no
      /proc/net/netstat = no
      /proc/net/snmp = no
      /proc/net/snmp6 = no
      /proc/net/sockstat = no
      /proc/net/sockstat6 = no
      /proc/net/softnet_stat = no
      /proc/net/ip_vs/stats = no
      /proc/interrupts = no
      /proc/softirqs = no
      /proc/pressure = no
      /proc/mdstat = no
      /proc/sys/kernel/random/entropy_avail = no
      /sys/devices/system/cpu/cpufreq = no
      /sys/devices/system/cpu/cpuidle = no
      /sys/class/power_supply = no
      /sys/class/infiniband = no
      
  stream.conf: |
    [stream]
      enabled = yes
      
  health_alarm_notify.conf: |
    SEND_EMAIL="NO"
    SEND_SLACK="NO"
    SEND_DISCORD="NO"
    SEND_TELEGRAM="NO"
EOF

# 3. Update child configuration
echo "Updating child configuration..."
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: netdata-conf-child
  namespace: netdata
data:
  netdata.conf: |
    [global]
      update every = 1
      memory mode = ram
      history = 3600
      
    [plugins]
      proc = yes
      apps = no
      cgroups = no
      tc = no
      diskspace = no
      go.d = no
      python.d = no
      charts.d = no
      node.d = no
      ebpf = no
      fping = no
      idlejitter = no
      ioping = no
      nfacct = no
      perf = no
      slabinfo = no
      statsd = no
      timex = no
      
    [plugin:proc]
      /proc/stat = yes
      /proc/meminfo = yes
      /proc/loadavg = yes
      /proc/uptime = yes
      /proc/vmstat = no
      /proc/net/dev = no
      /proc/diskstats = no
      /proc/net/netstat = no
      /proc/net/snmp = no
      /proc/net/snmp6 = no
      /proc/net/sockstat = no
      /proc/net/sockstat6 = no
      /proc/net/softnet_stat = no
      /proc/net/ip_vs/stats = no
      /proc/interrupts = no
      /proc/softirqs = no
      /proc/pressure = no
      /proc/mdstat = no
      /proc/sys/kernel/random/entropy_avail = no
      /sys/devices/system/cpu/cpufreq = no
      /sys/devices/system/cpu/cpuidle = no
      /sys/class/power_supply = no
      /sys/class/infiniband = no
      
  stream.conf: |
    [stream]
      enabled = yes
      destination = netdata:19999
      api key = 11111111-2222-3333-4444-555555555555
      
  health_alarm_notify.conf: |
    SEND_EMAIL="NO"
    SEND_SLACK="NO"
    SEND_DISCORD="NO"
    SEND_TELEGRAM="NO"
    
  coredns.conf: |
    update_every: 0
    autodetection_retry: 0
    
  kubelet.conf: |
    update_every: 0
    autodetection_retry: 0
    
  kubeproxy.conf: |
    update_every: 0
    autodetection_retry: 0
EOF

# 4. Scale down k8s-state deployment (not needed for basic metrics)
echo "Disabling k8s-state metrics collection..."
kubectl scale deployment netdata-k8s-state -n netdata --replicas=0

# 5. Restart pods to apply new configuration
echo "Restarting Netdata pods to apply configuration..."
kubectl rollout restart deployment netdata-parent -n netdata
kubectl rollout restart daemonset netdata-child -n netdata

# 6. Wait for rollout to complete
echo "Waiting for pods to restart..."
kubectl rollout status deployment netdata-parent -n netdata --timeout=120s
kubectl rollout status daemonset netdata-child -n netdata --timeout=120s

echo ""
echo "=== Configuration Complete ==="
kubectl get pods -n netdata
echo ""
echo "Netdata is now configured to collect only:"
echo "  ✓ CPU utilization"
echo "  ✓ Memory usage"
echo "  ✓ System load"
echo "  ✓ Node uptime"
echo ""
echo "Access points:"
echo "  - Web UI: http://netdata.k8s.local"
echo "  - API: http://api.catdevops.net"
echo "  - Port forward: kubectl port-forward -n netdata svc/netdata 19999:19999"