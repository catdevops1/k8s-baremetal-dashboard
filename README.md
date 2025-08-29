# 🚀 Kubernetes Bare-Metal Dashboard

> **Live demonstration of a production-ready bare-metal Kubernetes cluster with real-time monitoring and professional web interface**

[![Cluster Status](https://img.shields.io/badge/Cluster-Operational-green?style=for-the-badge&logo=kubernetes)](https://catdevops.net)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.33.3-blue?style=for-the-badge&logo=kubernetes)](https://kubernetes.io)
[![SSL](https://img.shields.io/badge/SSL-Let's_Encrypt-green?style=for-the-badge&logo=letsencrypt)](https://catdevops.net)

## 🌐 Live Website
**Main Dashboard**: [catdevops.net](https://catdevops.net)  
**Monitoring**: [app.catdevops.net](https://app.catdevops.net) (Netdata)

## 📊 Current Status
```
🖥️  Nodes:     3/3 Ready
🚀 Pods:      25+ Running  
🌐 Services:  12 Active
🔒 SSL:       Valid (Let's Encrypt)
☁️  Tunnel:    Connected (Cloudflare)
⏰ Uptime:    18+ days
```

## 🏗️ Architecture

### Infrastructure Stack
- **Platform**: Bare-metal servers (home lab)
- **Container Runtime**: containerd  
- **CNI**: Flannel networking
- **Load Balancer**: MetalLB (Layer 2)
- **Ingress Controller**: Nginx
- **External Access**: Cloudflare Tunnel (bypasses ISP port blocking)
- **SSL/TLS**: cert-manager + Let's Encrypt
- **Storage**: Local persistent volumes
- **Monitoring**: Netdata DaemonSet + custom dashboard

### Network Flow
```
Internet → Cloudflare Edge → Tunnel → Kubernetes Ingress → Services → Pods
```

## 🚀 Quick Start

### One-Command Setup
```bash
# Download and run setup script
curl -sSL https://raw.githubusercontent.com/catdevops1/k8s-baremetal-dashboard/main/setup.sh | bash
```

### Manual Setup
```bash
# Clone repository
git clone git@github.com:catdevops1/k8s-baremetal-dashboard.git
cd k8s-baremetal-dashboard

# Run setup
./setup.sh

# Or deploy manually
./scripts/deploy.sh
```

## 📁 Project Structure
```
k8s-baremetal-dashboard/
├── 📁 applications/
│   └── showcase-website/
│       ├── frontend/src/          # Website source code
│       └── k8s-manifests/         # Kubernetes configurations
├── 📁 scripts/                    # Management scripts
│   ├── deploy.sh                  # Deploy/update website
│   ├── health-check.sh            # Cluster health monitoring
│   ├── update-website.sh          # Update website content
│   └── view-logs.sh               # View application logs
├── 📁 infrastructure/             # Infrastructure as Code
├── 📁 docs/                       # Documentation
└── README.md                      # This file
```

## 🛠️ Management Commands

```bash
# Deploy or update website
./scripts/deploy.sh

# Check cluster and application health
./scripts/health-check.sh

# Update website content
./scripts/update-website.sh

# View application logs
./scripts/view-logs.sh

# View live logs (follow mode)
./scripts/view-logs.sh follow
```

## 🔧 Features Demonstrated

### Kubernetes Concepts
- [x] **Multi-node bare-metal cluster** deployment and management
- [x] **MetalLB LoadBalancer** services on bare metal
- [x] **Nginx Ingress Controller** with SSL termination
- [x] **Persistent storage** with local volumes
- [x] **ConfigMaps and Secrets** management
- [x] **Resource limits** and health checks
- [x] **Rolling deployments** and scaling

### DevOps Best Practices
- [x] **Infrastructure as Code** (YAML manifests)
- [x] **GitOps workflow** (Git-based deployment)
- [x] **Automated SSL certificates** (cert-manager)
- [x] **Real-time monitoring** (Netdata + custom dashboard)
- [x] **Professional documentation**
- [x] **Automation scripts** for management

### Networking Solutions
- [x] **Cloudflare Tunnel** (bypassing ISP restrictions)
- [x] **Load balancing** on bare metal infrastructure
- [x] **Multi-domain routing** through ingress
- [x] **SSL/TLS automation** and certificate management

## 🌍 Why This Project Matters

This project demonstrates real-world skills:

1. **Production Kubernetes** deployment on bare-metal infrastructure
2. **Cost-effective alternative** to expensive cloud solutions
3. **Network engineering** solutions (bypassing ISP limitations)
4. **Security implementation** (SSL automation, secure tunneling)
5. **Monitoring and observability** (real-time metrics and dashboards)
6. **Professional presentation** (polished web interface)

## 📊 Performance Metrics

Current cluster performance (live data):
- **Average Response Time**: < 100ms
- **Uptime**: 99.9%+
- **SSL Rating**: A+ (SSL Labs)
- **Load Time**: < 2s (fully loaded)
- **Resource Utilization**: CPU ~25%, Memory ~65%

## 🚨 Troubleshooting

### Common Issues

**Website not accessible?**
```bash
# Check DNS and ingress
./scripts/health-check.sh
nslookup catdevops.net
kubectl get ingress showcase-website
```

**Pods not starting?**
```bash
# Check pod status and events
kubectl get pods -l app=showcase-website
kubectl describe pods -l app=showcase-website
kubectl get events --sort-by=.metadata.creationTimestamp
```

**SSL certificate issues?**
```bash
# Check certificate status
kubectl get certificate -A
kubectl describe certificate catdevops-net-tls
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Kubernetes Community** - Amazing container orchestration platform
- **MetalLB** - Making LoadBalancer services possible on bare metal
- **Cloudflare** - Tunnel technology and global CDN
- **Let's Encrypt** - Free SSL certificates for everyone
- **Netdata** - Incredible real-time monitoring solution

## 📞 Contact & Support

- **Live Website**: [catdevops.net](https://catdevops.net)
- **GitHub**: [@catdevops1](https://github.com/catdevops1)
- **Issues**: [Report a bug](https://github.com/catdevops1/k8s-baremetal-dashboard/issues)

---

**⭐ If this project helped you learn Kubernetes or inspired your homelab setup, please give it a star!**

> *"The best way to learn Kubernetes is to run it in production. The second best way is to run it at home."*

**Built with ❤️ using bare-metal infrastructure, open-source tools, and a passion for technology.**
