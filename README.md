# OpenShift Trial - Infrastructure as Code

This repository contains Infrastructure as Code (IaC) configurations for OpenShift cluster management and application deployments.

## 📁 Repository Structure

```
ocp-trial/
├── manifests/           # Kubernetes/OpenShift YAML manifests
│   ├── namespaces/      # Namespace definitions
│   ├── deployments/     # Deployment configurations
│   ├── services/        # Service definitions
│   ├── configmaps/      # ConfigMap resources
│   ├── secrets/         # Secret templates (no actual secrets)
│   └── routes/          # OpenShift Route definitions
├── scripts/             # Deployment and utility scripts
├── docs/                # Documentation
├── examples/            # Example configurations
└── README.md           # This file
```

## 🚀 Getting Started

### Prerequisites

- OpenShift CLI (`oc`) installed and configured
- Access to an OpenShift cluster
- Git installed

### Setup

1. Clone this repository:
   ```bash
   git clone <your-github-repo-url>
   cd ocp-trial
   ```

2. Login to your OpenShift cluster:
   ```bash
   oc login --token=<your-token> --server=<your-server-url>
   ```

3. Verify access:
   ```bash
   oc get projects
   ```

### Deployment

1. Apply namespace configurations:
   ```bash
   oc apply -f manifests/namespaces/
   ```

2. Deploy applications:
   ```bash
   oc apply -f manifests/deployments/
   oc apply -f manifests/services/
   oc apply -f manifests/routes/
   ```

## 🔧 Available Scripts

Scripts are located in the `scripts/` directory:

- `deploy.sh` - Complete deployment script
- `cleanup.sh` - Cleanup script for resources
- `health-check.sh` - Health check utilities

## 📚 Documentation

- [Getting Started Guide](docs/getting-started.md)
- [Deployment Guide](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- [OpenShift Documentation](https://docs.openshift.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Infrastructure as Code Best Practices](https://docs.microsoft.com/en-us/azure/devops/learn/what-is-infrastructure-as-code)
