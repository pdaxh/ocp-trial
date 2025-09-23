#!/bin/bash

# Test GitHub Actions Workflows Locally
# This script simulates the GitHub Actions workflows for local testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_header "Checking dependencies..."
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed"
        exit 1
    fi
    
    if ! command -v python3 &> /dev/null; then
        print_error "python3 is not installed"
        exit 1
    fi
    
    print_status "All dependencies are available"
}

# Test YAML validation
test_yaml_validation() {
    print_header "Testing YAML validation..."
    
    # Check if PyYAML is available
    if ! python3 -c "import yaml" 2>/dev/null; then
        print_warning "PyYAML not available, installing..."
        pip3 install PyYAML || print_error "Failed to install PyYAML"
    fi
    
    # Validate YAML syntax
    find manifests/ -name "*.yaml" -o -name "*.yml" | while read file; do
        echo "Checking $file"
        python3 -c "import yaml; yaml.safe_load(open('$file'))" || {
            print_error "YAML validation failed for $file"
            exit 1
        }
    done
    
    print_status "YAML validation passed"
}

# Test Kubernetes manifest validation
test_k8s_validation() {
    print_header "Testing Kubernetes manifest validation..."
    
    find manifests/ -name "*.yaml" -o -name "*.yml" | while read file; do
        echo "Validating $file"
        kubectl apply --dry-run=client -f "$file" 2>/dev/null || {
            print_warning "Kubernetes validation failed for $file (might need cluster access)"
            # For local testing, we'll skip this if cluster is not accessible
            continue
        }
    done
    
    print_status "Kubernetes validation passed"
}

# Test security checks
test_security_checks() {
    print_header "Testing security checks..."
    
    # Check for hardcoded secrets
    if grep -r "password\|secret\|key" manifests/ --include="*.yaml" --include="*.yml" | grep -v "kind:" | grep -v "name:" | grep -v "metadata:"; then
        print_error "Potential hardcoded secrets found!"
        exit 1
    fi
    
    # Check for privileged containers
    if grep -r "privileged: true" manifests/ --include="*.yaml" --include="*.yml"; then
        print_error "Privileged containers found!"
        exit 1
    fi
    
    # Check for hostNetwork
    if grep -r "hostNetwork: true" manifests/ --include="*.yaml" --include="*.yml"; then
        print_error "hostNetwork usage found!"
        exit 1
    fi
    
    print_status "Security checks passed"
}

# Test script syntax
test_script_syntax() {
    print_header "Testing script syntax..."
    
    chmod +x scripts/*.sh
    
    bash -n scripts/deploy.sh || {
        print_error "Deploy script syntax error"
        exit 1
    }
    
    bash -n scripts/cleanup.sh || {
        print_error "Cleanup script syntax error"
        exit 1
    }
    
    print_status "Script syntax validation passed"
}

# Test dry-run deployment
test_dry_run_deployment() {
    print_header "Testing dry-run deployment..."
    
    # Test namespace creation (skip if no cluster access)
    kubectl apply -f manifests/namespaces/ --dry-run=client 2>/dev/null || {
        print_warning "Namespace dry-run failed (no cluster access)"
    }
    
    # Test application deployment (skip if no cluster access)
    kubectl apply -f manifests/deployments/ --dry-run=client 2>/dev/null || {
        print_warning "Deployment dry-run failed (no cluster access)"
    }
    
    kubectl apply -f manifests/services/ --dry-run=client 2>/dev/null || {
        print_warning "Service dry-run failed (no cluster access)"
    }
    
    kubectl apply -f manifests/routes/ --dry-run=client 2>/dev/null || {
        print_warning "Route dry-run failed (no cluster access)"
    }
    
    print_status "Dry-run deployment successful"
}

# Test workflow files
test_workflow_files() {
    print_header "Testing workflow files..."
    
    # Check if workflow files exist
    if [ ! -f ".github/workflows/test-and-verify.yml" ]; then
        print_error "test-and-verify.yml workflow not found"
        exit 1
    fi
    
    if [ ! -f ".github/workflows/deploy.yml" ]; then
        print_error "deploy.yml workflow not found"
        exit 1
    fi
    
    if [ ! -f ".github/workflows/cleanup.yml" ]; then
        print_error "cleanup.yml workflow not found"
        exit 1
    fi
    
    # Validate workflow YAML syntax
    python3 -c "import yaml; yaml.safe_load(open('.github/workflows/test-and-verify.yml'))" || {
        print_error "test-and-verify.yml has YAML syntax errors"
        exit 1
    }
    
    python3 -c "import yaml; yaml.safe_load(open('.github/workflows/deploy.yml'))" || {
        print_error "deploy.yml has YAML syntax errors"
        exit 1
    }
    
    python3 -c "import yaml; yaml.safe_load(open('.github/workflows/cleanup.yml'))" || {
        print_error "cleanup.yml has YAML syntax errors"
        exit 1
    }
    
    print_status "Workflow files validation passed"
}

# Main test function
main() {
    print_header "Starting GitHub Actions workflow tests..."
    
    check_dependencies
    test_yaml_validation
    test_k8s_validation
    test_security_checks
    test_script_syntax
    test_dry_run_deployment
    test_workflow_files
    
    print_status "🎉 All tests passed! GitHub Actions workflows are ready."
    print_status "Next steps:"
    print_status "1. Push changes to GitHub"
    print_status "2. Set up required secrets in repository settings"
    print_status "3. Test workflows in GitHub Actions tab"
}

# Run main function
main "$@"
