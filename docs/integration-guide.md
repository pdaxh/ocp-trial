# Multi-Repository Integration Guide

This guide explains how to manage multiple repositories while maintaining centralized infrastructure management.

## Repository Structure

### ocp-trial (Infrastructure Repository)
- **Purpose**: Centralized infrastructure as code
- **Contains**: BuildConfigs, deployment manifests, CI/CD workflows
- **Manages**: All OpenShift resources and deployment automation

### ULP/python-app (Application Repository)
- **Purpose**: Application source code and application-specific infrastructure
- **Contains**: Source code, Dockerfile, Helm charts, application manifests
- **Manages**: Application development and application-specific configurations

## Integration Strategy

### 1. Cross-Repository References

The ocp-trial repository references applications in other repositories:

```yaml
# ocp-trial/manifests/buildconfigs/python-app-build.yaml
spec:
  source:
    type: Git
    git:
      uri: https://github.com/your-org/ULP.git
      contextDir: python-app
```

### 2. Centralized Deployment

All deployments are managed from ocp-trial:

```bash
# Deploy all applications
oc apply -f manifests/buildconfigs/
oc apply -f manifests/deployments/
```

### 3. Application-Specific Workflows

Each application repository can have its own CI/CD for:
- Code quality checks
- Unit tests
- Security scanning
- Application-specific builds

### 4. Infrastructure Workflows

The ocp-trial repository handles:
- Infrastructure validation
- Cross-application deployments
- Environment management
- Resource cleanup

## Benefits of This Approach

### ✅ Advantages
1. **Separation of Concerns**: Infrastructure vs application code
2. **Independent Lifecycles**: Apps can be updated independently
3. **Team Ownership**: Different teams can own different repos
4. **Scalability**: Easy to add new applications
5. **Reusability**: Infrastructure patterns can be reused

### ⚠️ Considerations
1. **Coordination**: Need to coordinate between repositories
2. **Dependencies**: Infrastructure changes might affect applications
3. **Documentation**: Need to maintain cross-repository documentation

## Implementation Steps

### 1. Update BuildConfig References

Update the BuildConfig to point to your actual ULP repository:

```yaml
spec:
  source:
    git:
      uri: https://github.com/your-actual-org/ULP.git
```

### 2. Create Application Deployment Manifests

Create deployment manifests in ocp-trial that reference the built images:

```yaml
# ocp-trial/manifests/deployments/python-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
spec:
  template:
    spec:
      containers:
      - name: python-app
        image: python-app:latest
        imagePullPolicy: Always
```

### 3. Set Up Cross-Repository Webhooks

Configure webhooks so that:
- ULP repository changes trigger builds in ocp-trial
- ocp-trial changes trigger deployments

### 4. Create Integration Scripts

```bash
# ocp-trial/scripts/deploy-all-apps.sh
#!/bin/bash
echo "Deploying all applications..."

# Deploy infrastructure
oc apply -f manifests/buildconfigs/
oc apply -f manifests/deployments/

# Start builds
oc start-build python-app-build --follow
oc start-build nginx-dockerfile-build --follow

echo "All applications deployed!"
```

## Best Practices

### 1. Naming Conventions
- Use consistent naming across repositories
- Include repository source in labels
- Use semantic versioning

### 2. Documentation
- Document cross-repository dependencies
- Maintain integration guides
- Keep README files updated

### 3. Monitoring
- Set up monitoring for cross-repository builds
- Use consistent logging and alerting
- Track deployment status across repositories

### 4. Security
- Use consistent security policies
- Implement proper access controls
- Regular security scanning

## Migration Strategy

If you decide to move everything to ocp-trial later:

1. **Phase 1**: Keep current structure, add integration
2. **Phase 2**: Gradually move application-specific configs
3. **Phase 3**: Consider full migration if needed

## Example Workflow

```bash
# 1. Make changes to ULP/python-app
cd ULP/python-app
git add .
git commit -m "Update Python app"
git push

# 2. Deploy from ocp-trial
cd ocp-trial
oc start-build python-app-build --follow

# 3. Deploy all applications
./scripts/deploy-all-apps.sh
```

This approach gives you the best of both worlds: centralized infrastructure management with application-specific flexibility.
