# Getting Started with OpenShift Trial

This guide will help you get started with the OpenShift Trial project.

## Prerequisites

Before you begin, ensure you have the following installed:

- **OpenShift CLI (oc)**: Download from [Red Hat Developer](https://developers.redhat.com/products/openshift/overview)
- **Git**: For version control
- **Access to OpenShift cluster**: Either a local cluster or cloud-based (like OpenShift Developer Sandbox)

## Initial Setup

### 1. Clone the Repository

```bash
git clone <your-github-repo-url>
cd ocp-trial
```

### 2. Login to OpenShift

```bash
oc login --token=<your-token> --server=<your-server-url>
```

### 3. Verify Access

```bash
oc get projects
oc whoami
```

## Quick Start

### Deploy the Demo Application

1. Run the deployment script:
   ```bash
   ./scripts/deploy.sh
   ```

2. Check the deployment status:
   ```bash
   oc get all -n demo-namespace
   ```

3. Access the application:
   ```bash
   oc get route nginx-route -n demo-namespace
   ```

### Clean Up

To remove the demo application:

```bash
./scripts/cleanup.sh
```

## Manual Deployment

If you prefer to deploy manually:

1. Create the namespace:
   ```bash
   oc apply -f manifests/namespaces/
   ```

2. Deploy the application:
   ```bash
   oc apply -f manifests/deployments/
   oc apply -f manifests/services/
   oc apply -f manifests/routes/
   ```

## Troubleshooting

### Common Issues

1. **Authentication Error**: Make sure you're logged in with a valid token
2. **Permission Denied**: Check if you have the necessary permissions in the cluster
3. **Resource Not Found**: Ensure the namespace exists before deploying resources

### Useful Commands

```bash
# Check cluster status
oc cluster-info

# View all resources in namespace
oc get all -n demo-namespace

# View pod logs
oc logs deployment/nginx-demo -n demo-namespace

# Describe a resource
oc describe deployment nginx-demo -n demo-namespace
```

## Next Steps

- Explore the manifests in the `manifests/` directory
- Customize the configurations for your needs
- Add more applications following the same pattern
- Set up CI/CD pipelines for automated deployments
