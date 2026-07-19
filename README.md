# Production Kubernetes on Bare Metal

Production-grade 5-node bare-metal Kubernetes cluster with real-time monitoring, GitOps deployments, and Vault-managed secrets.

**Live:** [catdevops.net](https://catdevops.net)
**Live Metrics:** [metrics.catdevops.net](https://metrics.catdevops.net)

## Cluster Overview

| Component | Details |
|---|---|
| Kubernetes | v1.35.0 |
| Nodes | 5 (1 control-plane + 4 workers) |
| Runtime | containerd |
| OS | Ubuntu 24.04 LTS |
| Uptime | 343+ days |

## Architecture

```
Internet → Cloudflare Edge → Tunnel → Envoy Gateway → Services → Pods
```

### Networking
- **CNI:** Flannel
- **Load Balancer:** MetalLB (Layer 2)
- **Gateway:** Envoy Gateway (Gateway API)
- **External Access:** Cloudflare Tunnel
- **TLS:** cert-manager + Let's Encrypt

### Storage & Secrets
- **Storage:** Longhorn (distributed block storage)
- **Secrets:** HashiCorp Vault with AWS KMS auto-unseal
- **Secret Sync:** External Secrets Operator → Vault KV

### GitOps & Observability
- **CD:** ArgoCD (auto-sync enabled)
- **Monitoring:** Netdata (parent-child streaming architecture)
- **Metrics:** metrics-server (hostNetwork, port 4443)

## What's In This Repo

| Component | Stack | Description |
|---|---|---|
| [Showcase Website](https://catdevops.net) | HTML/JS · Nginx | Live cluster metrics dashboard with real-time node stats |
| Netdata Metrics API | Nginx · Python · kubectl | Reverse proxy + sidecar that serves per-node metrics and cluster info |
| Netdata Parent | Netdata · Vault/ESO | Streaming aggregator with Vault-managed API key via init container |

## Secrets Management

Application secrets are managed through Vault with zero secrets in git:

```
Vault (in-cluster, KMS auto-unseal)
    ↓
External Secrets Operator (watches ExternalSecret CRDs)
    ↓
Kubernetes Secrets (auto-refreshed hourly)
    ↓
Application pods
```

The Netdata streaming key uses an init container pattern — the ConfigMap holds a placeholder, and a busybox init container injects the real key from the Vault-synced Secret before the main container starts.

## Repository Structure

```
k8s-baremetal-dashboard/
├── applications/
│   ├── monitoring/netdat-dash/     # Netdata parent + metrics API
│   │   ├── netdata-parent-config.yaml
│   │   ├── netdata-parent-deployment.yaml
│   │   ├── cluster-info-script-configmap.yaml
│   │   ├── minimal-api-*.yaml      # Nginx reverse proxy for metrics
│   │   └── rbac.yaml
│   └── showcase-website/           # catdevops.net
│       ├── frontend/src/
│       └── k8s-manifests/
├── argocd/applications/            # ArgoCD app definitions
├── values.yaml                     # Helm values (Netdata chart)
└── README.md
```

## Related Repositories

| Repository | Purpose |
|---|---|
| [homelab-k8s-config-pub](https://github.com/catdevops1/homelab-k8s-config-pub) | Vault, ESO, Cloudflare Tunnel, Envoy Gateway, ExternalSecrets |
| [cluster-ai](https://github.com/catdevops1/cluster-ai) | Autonomous cluster monitoring agent |
| [vault-config-pub](https://github.com/catdevops1/vault-config-pub) | Vault configuration reference |

## How It Works

The showcase website at [catdevops.net](https://catdevops.net) displays live cluster metrics by running a sidecar architecture:

1. **Netdata child agents** (DaemonSet) collect host metrics on each node
2. **Nginx reverse proxy** (minimal-api) forwards per-node metric requests to each child's Netdata API
3. **Python sidecar** (cluster-info-script) runs kubectl to provide cluster-level data (pod counts, node info)
4. **Frontend JS** polls both endpoints every 5 seconds and renders the dashboard

All infrastructure changes deploy through ArgoCD — push to main, ArgoCD syncs, pods roll out.

## Contact

- **GitHub:** [@catdevops1](https://github.com/catdevops1/k8s-baremetal-dashboard)
- **LinkedIn:** [Catalin Bot](https://www.linkedin.com/in/catalin-bot/)


**Built with ❤️ using bare-metal infrastructure, open-source tools, and a passion for technology.**
