# GitHub Actions Setup Guide

This guide explains how to set up and configure GitHub Actions for your OpenShift Trial repository.

## Overview

The repository includes three GitHub Actions workflows:

1. **Test and Verify** (`.github/workflows/test-and-verify.yml`)
   - Validates Kubernetes manifests
   - Tests deployment scripts
   - Lints documentation
   - Runs security scans
   - Performs integration tests

2. **Deploy** (`.github/workflows/deploy.yml`)
   - Deploys application to OpenShift
   - Runs on pushes to main branch
   - Can be triggered manually

3. **Cleanup** (`.github/workflows/cleanup.yml`)
   - Removes OpenShift resources
   - Manual trigger only with confirmation

## Required GitHub Secrets

To use the deployment and cleanup workflows, you need to configure the following secrets in your GitHub repository:

### Setting up Secrets

1. Go to your GitHub repository: `https://github.com/pdaxh/ocp-trial`
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret** for each secret below:

### Required Secrets

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `OPENSHIFT_TOKEN` | Your OpenShift authentication token | `sha256~QjpGus0nVZaC3Zil5NovnlxoLtxV_3bvqRNECDQV_m8` |
| `OPENSHIFT_SERVER` | Your OpenShift cluster server URL | `https://api.rm1.0a51.p1.openshiftapps.com:6443` |
| `OPENSHIFT_PROJECT` | Your OpenShift project name | `daaxh25-dev` |

### How to Get Your Values

#### OpenShift Token
```bash
# Get your current token
oc whoami -t
```

#### OpenShift Server
```bash
# Get your current server
oc config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```

#### OpenShift Project
```bash
# Get your current project
oc project -q
```

## Workflow Triggers

### Automatic Triggers

- **Test and Verify**: Runs on every push and pull request
- **Deploy**: Runs on pushes to main branch (only when manifests change)

### Manual Triggers

- **Deploy**: Can be triggered manually with environment selection
- **Cleanup**: Manual trigger only (requires confirmation)

## Using the Workflows

### 1. Test and Verify Workflow

This workflow runs automatically and includes:

- **YAML Validation**: Checks syntax and Kubernetes compatibility
- **Security Scanning**: Looks for hardcoded secrets and security issues
- **Script Testing**: Validates deployment scripts
- **Documentation Linting**: Checks markdown files
- **Integration Testing**: Dry-run deployment tests

### 2. Deploy Workflow

#### Automatic Deployment
- Triggers when you push changes to the `main` branch
- Only runs if files in `manifests/` or `scripts/` directories change

#### Manual Deployment
1. Go to **Actions** tab in your GitHub repository
2. Select **Deploy to OpenShift** workflow
3. Click **Run workflow**
4. Choose environment (development/staging/production)
5. Click **Run workflow**

### 3. Cleanup Workflow

#### Manual Cleanup
1. Go to **Actions** tab in your GitHub repository
2. Select **Cleanup OpenShift Resources** workflow
3. Click **Run workflow**
4. Type `yes` in the confirmation field
5. Choose environment to cleanup
6. Click **Run workflow**

## Workflow Status

You can monitor workflow status:

1. **Actions Tab**: View all workflow runs
2. **Commit Status**: See status badges on commits
3. **Pull Requests**: View test results on PRs

## Customization

### Adding New Environments

To add new environments (e.g., `staging`):

1. Update workflow files to include new environment options
2. Create corresponding GitHub environments in repository settings
3. Configure environment-specific secrets if needed

### Modifying Triggers

Edit the `on:` section in workflow files:

```yaml
on:
  push:
    branches: [ main, develop ]  # Add more branches
  pull_request:
    branches: [ main, develop ]  # Add more branches
```

### Adding New Tests

To add new validation steps:

1. Add new steps to the `test-and-verify.yml` workflow
2. Use appropriate GitHub Actions or custom scripts
3. Update the `notify-results` job to include new test results

## Troubleshooting

### Common Issues

1. **Authentication Failures**
   - Verify secrets are correctly set
   - Check token hasn't expired
   - Ensure server URL is correct

2. **Permission Errors**
   - Verify OpenShift project permissions
   - Check if user has necessary roles

3. **Workflow Failures**
   - Check workflow logs in Actions tab
   - Verify all required secrets are set
   - Test scripts locally first

### Getting Help

- Check workflow logs in GitHub Actions tab
- Review OpenShift cluster events: `oc get events`
- Test deployment locally: `./scripts/deploy.sh`

## Security Considerations

- Never commit secrets to the repository
- Use GitHub Secrets for sensitive information
- Regularly rotate OpenShift tokens
- Review workflow permissions and access

## Next Steps

1. Set up the required GitHub secrets
2. Test the workflows with a small change
3. Configure branch protection rules
4. Set up notifications for workflow results
5. Consider adding more environments as needed
