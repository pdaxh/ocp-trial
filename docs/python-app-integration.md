# Python Application Integration Guide

This guide explains how to integrate your Python application from the ULP project folder into the ocp-trial infrastructure.

## Prerequisites

Before integrating your Python application, ensure you have:

1. **Python application repository** on GitHub/GitLab
2. **Dockerfile** in your Python application repository
3. **OpenShift cluster access** with appropriate permissions

## Integration Steps

### 1. Prepare Your Python Application Repository

Your Python application repository should have this structure:

```
your-python-app-repo/
├── src/
│   ├── app.py
│   └── requirements.txt
├── Docker/
│   └── Dockerfile
├── k8s/                    # Optional: K8s manifests
├── openshift/              # Optional: OpenShift manifests
├── helm/                   # Optional: Helm charts
└── README.md
```

### 2. Update BuildConfig

Edit `manifests/buildconfigs/python-app-build.yaml`:

```yaml
spec:
  source:
    type: Git
    git:
      uri: https://github.com/your-username/your-python-app-repo.git
      ref: main
      contextDir: .  # or subdirectory if needed
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Docker/Dockerfile  # Adjust path as needed
```

### 3. Create ImageStream

Create the ImageStream for your Python application:

```bash
oc create imagestream python-app
```

### 4. Deploy BuildConfig

```bash
oc apply -f manifests/buildconfigs/python-app-build.yaml
```

### 5. Start Build

```bash
oc start-build python-app-build --follow
```

## BuildConfig Customization Options

### Source Configuration

```yaml
source:
  type: Git
  git:
    uri: https://github.com/your-username/repo.git
    ref: main                    # Branch or tag
    contextDir: python-app       # Subdirectory (optional)
  # Optional: Use specific commit
  # git:
  #   uri: https://github.com/your-username/repo.git
  #   ref: abc123def456
```

### Build Strategy Options

#### Docker Strategy
```yaml
strategy:
  type: Docker
  dockerStrategy:
    dockerfilePath: Docker/Dockerfile
    buildArgs:
    - name: BUILD_ARG
      value: "value"
```

#### Source-to-Image (S2I) Strategy
```yaml
strategy:
  type: Source
  sourceStrategy:
    from:
      kind: ImageStreamTag
      name: python:3.9
      namespace: openshift
    env:
    - name: PIP_INDEX_URL
      value: "https://pypi.org/simple/"
```

### Output Configuration

```yaml
output:
  to:
    kind: ImageStreamTag
    name: python-app:latest
  # Optional: Push to external registry
  # to:
  #   kind: DockerImage
  #   name: registry.example.com/python-app:latest
  # pushSecret:
  #   name: registry-secret
```

### Build Triggers

#### Manual Trigger
```yaml
triggers:
- type: ConfigChange
```

#### GitHub Webhook
```yaml
triggers:
- type: GitHub
  github:
    secret: github-webhook-secret
```

#### Generic Webhook
```yaml
triggers:
- type: Generic
  generic:
    secret: generic-webhook-secret
```

## Deployment Integration

### 1. Create Deployment Manifest

Create `manifests/deployments/python-app-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
  namespace: daaxh25-dev
  labels:
    app: python-app
    environment: development
    managed-by: iac
spec:
  replicas: 2
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: python-app
        image: python-app:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        env:
        - name: FLASK_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

### 2. Create Service

Create `manifests/services/python-app-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: python-app-service
  namespace: daaxh25-dev
  labels:
    app: python-app
    environment: development
    managed-by: iac
spec:
  selector:
    app: python-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
    name: http
  type: ClusterIP
```

### 3. Create Route

Create `manifests/routes/python-app-route.yaml`:

```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: python-app-route
  namespace: daaxh25-dev
  labels:
    app: python-app
    environment: development
    managed-by: iac
spec:
  host: python-app-demo-namespace.apps.rm1.0a51.p1.openshiftapps.com
  to:
    kind: Service
    name: python-app-service
    weight: 100
  port:
    targetPort: http
  tls:
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

## Testing the Integration

### 1. Deploy All Resources

```bash
# Create ImageStream
oc create imagestream python-app

# Deploy BuildConfig
oc apply -f manifests/buildconfigs/python-app-build.yaml

# Deploy application
oc apply -f manifests/deployments/python-app-deployment.yaml
oc apply -f manifests/services/python-app-service.yaml
oc apply -f manifests/routes/python-app-route.yaml
```

### 2. Start Build

```bash
oc start-build python-app-build --follow
```

### 3. Verify Deployment

```bash
# Check build status
oc get builds

# Check deployment status
oc get pods -l app=python-app

# Check service
oc get svc python-app-service

# Check route
oc get route python-app-route
```

### 4. Test Application

```bash
# Get application URL
oc get route python-app-route -o jsonpath='{.spec.host}'

# Test the application
curl https://python-app-demo-namespace.apps.rm1.0a51.p1.openshiftapps.com
```

## Troubleshooting

### Common Issues

1. **Build Fails**
   ```bash
   # Check build logs
   oc logs build/python-app-build-1
   
   # Check build details
   oc describe build python-app-build-1
   ```

2. **Image Pull Errors**
   ```bash
   # Check ImageStream
   oc describe imagestream python-app
   
   # Check if build completed
   oc get builds
   ```

3. **Deployment Issues**
   ```bash
   # Check pod logs
   oc logs deployment/python-app
   
   # Check pod events
   oc describe pod -l app=python-app
   ```

## Best Practices

1. **Use specific image tags** instead of `latest`
2. **Implement health checks** in your application
3. **Use resource limits** to prevent resource exhaustion
4. **Set up monitoring** and logging
5. **Use ConfigMaps** for configuration
6. **Implement proper security contexts**

## Next Steps

1. Update the BuildConfig with your actual repository URL
2. Customize the deployment manifests for your application
3. Set up webhooks for automated builds
4. Configure monitoring and logging
5. Set up CI/CD pipelines for your Python application repository
