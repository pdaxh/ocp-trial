# OpenShift BuildConfig Guide

This guide explains how to use OpenShift BuildConfigs to build container images from source code.

## What are BuildConfigs?

BuildConfigs are OpenShift resources that define how to build container images. They support multiple build strategies:

- **Docker Build**: Uses Dockerfile to build images
- **Source-to-Image (S2I)**: Uses prepared base images that accept source code
- **Custom Build**: Runs arbitrary container images as base

## BuildConfig Examples

### 1. Dockerfile Build

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nginx-dockerfile-build
spec:
  source:
    type: Git
    git:
      uri: https://github.com/pdaxh/ocp-trial.git
      ref: main
    contextDir: examples/dockerfile-app
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Dockerfile
  output:
    to:
      kind: ImageStreamTag
      name: nginx-demo:latest
```

### 2. Source-to-Image (S2I) Build

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: nodejs-s2i-build
spec:
  source:
    type: Git
    git:
      uri: https://github.com/pdaxh/ocp-trial.git
      ref: main
    contextDir: examples/nodejs-app
  strategy:
    type: Source
    sourceStrategy:
      from:
        kind: ImageStreamTag
        name: nodejs:18-ubi8
        namespace: openshift
  output:
    to:
      kind: ImageStreamTag
      name: nodejs-demo:latest
```

### 3. Webhook Build

```yaml
apiVersion: build.openshift.io/v1
kind: BuildConfig
metadata:
  name: webhook-build
spec:
  source:
    type: Git
    git:
      uri: https://github.com/pdaxh/ocp-trial.git
      ref: main
  strategy:
    type: Docker
    dockerStrategy:
      dockerfilePath: Dockerfile
  triggers:
  - type: GitHub
    github:
      secret: github-webhook-secret
  - type: Generic
    generic:
      secret: generic-webhook-secret
```

## Common BuildConfig Commands

### Creating BuildConfigs

```bash
# Create from YAML file
oc apply -f manifests/buildconfigs/nginx-dockerfile-build.yaml

# Create from template
oc new-app --name=my-app --dockerfile=./Dockerfile

# Create S2I build
oc new-app nodejs:18-ubi8~https://github.com/user/repo.git
```

### Managing Builds

```bash
# List BuildConfigs
oc get buildconfigs

# Start a build
oc start-build nginx-dockerfile-build

# Start build and follow logs
oc start-build nginx-dockerfile-build --follow

# List builds
oc get builds

# Show build logs
oc logs build/nginx-dockerfile-build-1

# Cancel a build
oc cancel-build nginx-dockerfile-build-1
```

### Working with ImageStreams

```bash
# List ImageStreams
oc get imagestreams

# Describe ImageStream
oc describe imagestream nginx-demo

# Tag an image
oc tag nginx-demo:latest nginx-demo:v1.0
```

## Build Triggers

### 1. Config Change Trigger
Automatically starts a new build when the BuildConfig changes:

```yaml
triggers:
- type: ConfigChange
```

### 2. Image Change Trigger
Starts a build when the base image changes:

```yaml
triggers:
- type: ImageChange
  imageChange:
    from:
      kind: ImageStreamTag
      name: nginx:latest
      namespace: openshift
```

### 3. GitHub Webhook Trigger
Starts a build when GitHub sends a webhook:

```yaml
triggers:
- type: GitHub
  github:
    secret: github-webhook-secret
```

### 4. Generic Webhook Trigger
Starts a build when a generic webhook is received:

```yaml
triggers:
- type: Generic
  generic:
    secret: generic-webhook-secret
```

## Setting up Webhooks

### GitHub Webhook Setup

1. Create webhook secret:
```bash
oc create secret generic github-webhook-secret \
  --from-literal=WebHookSecretKey=your-secret-key
```

2. Get webhook URL:
```bash
oc describe buildconfig webhook-build | grep -A 5 "GitHub"
```

3. Add webhook to GitHub repository:
   - Go to repository Settings → Webhooks
   - Add webhook URL
   - Select "Just the push event"
   - Add secret key

### Generic Webhook Setup

1. Create webhook secret:
```bash
oc create secret generic generic-webhook-secret \
  --from-literal=WebHookSecretKey=your-secret-key
```

2. Get webhook URL:
```bash
oc describe buildconfig webhook-build | grep -A 5 "Generic"
```

3. Trigger build:
```bash
curl -X POST -H "X-Secret-Token: your-secret-key" \
  https://your-webhook-url
```

## Build Strategies

### Docker Strategy
Uses Dockerfile to build images:

```yaml
strategy:
  type: Docker
  dockerStrategy:
    dockerfilePath: Dockerfile
    buildArgs:
    - name: BUILD_ARG
      value: "value"
```

### Source Strategy (S2I)
Uses Source-to-Image:

```yaml
strategy:
  type: Source
  sourceStrategy:
    from:
      kind: ImageStreamTag
      name: nodejs:18-ubi8
      namespace: openshift
    env:
    - name: NPM_MIRROR
      value: "https://registry.npmjs.org/"
```

### Custom Strategy
Uses custom builder image:

```yaml
strategy:
  type: Custom
  customStrategy:
    from:
      kind: ImageStreamTag
      name: custom-builder:latest
    env:
    - name: CUSTOM_VAR
      value: "value"
```

## Build Output

### ImageStream Output
Push to ImageStream:

```yaml
output:
  to:
    kind: ImageStreamTag
    name: my-app:latest
```

### Registry Output
Push to external registry:

```yaml
output:
  to:
    kind: DockerImage
    name: registry.example.com/my-app:latest
  pushSecret:
    name: registry-secret
```

## Build Policies

### Serial Policy
Only one build at a time:

```yaml
runPolicy: Serial
```

### SerialLatestOnly Policy
Only the latest build runs:

```yaml
runPolicy: SerialLatestOnly
```

### Parallel Policy
Multiple builds can run simultaneously:

```yaml
runPolicy: Parallel
```

## Troubleshooting

### Common Issues

1. **Build Fails**
   ```bash
   # Check build logs
   oc logs build/my-build-1
   
   # Check build events
   oc describe build my-build-1
   ```

2. **Image Pull Errors**
   ```bash
   # Check ImageStream
   oc describe imagestream my-image
   
   # Check if base image exists
   oc get imagestreams -n openshift | grep nodejs
   ```

3. **Webhook Not Triggering**
   ```bash
   # Check webhook secret
   oc get secret github-webhook-secret
   
   # Check webhook URL
   oc describe buildconfig webhook-build
   ```

### Useful Commands

```bash
# Get all build-related resources
oc get all -l app=my-app

# Check build status
oc get builds -w

# View build configuration
oc get buildconfig my-build -o yaml

# Export build configuration
oc get buildconfig my-build -o yaml > my-build.yaml
```

## Best Practices

1. **Use specific base images**: Avoid `latest` tags
2. **Implement health checks**: Add health check endpoints
3. **Use non-root users**: Set security contexts
4. **Optimize Dockerfiles**: Use multi-stage builds
5. **Monitor builds**: Set up alerts for failed builds
6. **Use build hooks**: Implement pre/post build hooks
7. **Cache dependencies**: Use build caches for faster builds

## Demo Script

Use the provided demo script to explore BuildConfigs:

```bash
./scripts/buildconfig-demo.sh
```

This script provides an interactive menu to:
- Create BuildConfigs
- Start builds
- View logs
- Manage ImageStreams
- Set up webhooks
