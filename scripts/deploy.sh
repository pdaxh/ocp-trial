#!/bin/bash

# OpenShift Trial - Deployment Script
# This script deploys the demo application to OpenShift

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if oc is installed
if ! command -v oc &> /dev/null; then
    print_error "OpenShift CLI (oc) is not installed or not in PATH"
    exit 1
fi

# Check if user is logged in
if ! oc whoami &> /dev/null; then
    print_error "Not logged in to OpenShift cluster. Please run 'oc login' first"
    exit 1
fi

print_status "Starting deployment to OpenShift cluster..."

# Get current project
CURRENT_PROJECT=$(oc project -q)
print_status "Current project: $CURRENT_PROJECT"

# Create namespace
print_status "Creating namespace..."
oc apply -f manifests/namespaces/

# Wait for namespace to be ready
print_status "Waiting for namespace to be ready..."
oc wait --for=condition=Ready namespace/demo-namespace --timeout=60s

# Deploy application
print_status "Deploying application..."
oc apply -f manifests/deployments/
oc apply -f manifests/services/
oc apply -f manifests/routes/

# Wait for deployment to be ready
print_status "Waiting for deployment to be ready..."
oc wait --for=condition=available deployment/nginx-demo -n demo-namespace --timeout=300s

# Get route information
print_status "Getting route information..."
ROUTE_URL=$(oc get route nginx-route -n demo-namespace -o jsonpath='{.spec.host}')
print_status "Application is available at: https://$ROUTE_URL"

# Show deployment status
print_status "Deployment completed successfully!"
print_status "To check the status, run: oc get all -n demo-namespace"
print_status "To view logs, run: oc logs deployment/nginx-demo -n demo-namespace"
