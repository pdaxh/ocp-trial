#!/bin/bash

# OpenShift Trial - Cleanup Script
# This script removes the demo application from OpenShift

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

print_status "Starting cleanup of demo application..."

# Get current project
CURRENT_PROJECT=$(oc project -q)
print_status "Current project: $CURRENT_PROJECT"

# Confirm deletion
read -p "Are you sure you want to delete the demo application? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Cleanup cancelled"
    exit 0
fi

# Delete resources
print_status "Deleting routes..."
oc delete -f manifests/routes/ --ignore-not-found=true

print_status "Deleting services..."
oc delete -f manifests/services/ --ignore-not-found=true

print_status "Deleting deployments..."
oc delete -f manifests/deployments/ --ignore-not-found=true

print_status "Deleting namespace..."
oc delete -f manifests/namespaces/ --ignore-not-found=true

print_status "Cleanup completed successfully!"
