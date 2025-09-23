#!/bin/bash

# OpenShift BuildConfig Demo Script
# This script demonstrates various BuildConfig operations

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
    echo -e "${BLUE}[DEMO]${NC} $1"
}

# Check if oc is installed and logged in
check_prerequisites() {
    print_header "Checking prerequisites..."
    
    if ! command -v oc &> /dev/null; then
        print_error "OpenShift CLI (oc) is not installed or not in PATH"
        exit 1
    fi
    
    if ! oc whoami &> /dev/null; then
        print_error "Not logged in to OpenShift cluster. Please run 'oc login' first"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Create BuildConfigs
create_buildconfigs() {
    print_header "Creating BuildConfigs..."
    
    # Apply BuildConfig manifests
    oc apply -f manifests/buildconfigs/
    
    print_status "BuildConfigs created successfully"
}

# List BuildConfigs
list_buildconfigs() {
    print_header "Listing BuildConfigs..."
    
    oc get buildconfigs -o wide
    
    print_status "BuildConfigs listed"
}

# Start builds
start_builds() {
    print_header "Starting builds..."
    
    # Start Dockerfile build
    print_status "Starting Dockerfile build..."
    oc start-build nginx-dockerfile-build --follow
    
    # Start S2I build
    print_status "Starting Source-to-Image build..."
    oc start-build nodejs-s2i-build --follow
    
    print_status "Builds completed"
}

# List builds
list_builds() {
    print_header "Listing builds..."
    
    oc get builds -o wide
    
    print_status "Builds listed"
}

# Show build logs
show_build_logs() {
    print_header "Showing build logs..."
    
    # Get the latest build for each BuildConfig
    NGINX_BUILD=$(oc get builds -l buildconfig=nginx-dockerfile-build --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
    NODEJS_BUILD=$(oc get builds -l buildconfig=nodejs-s2i-build --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1].metadata.name}')
    
    if [ ! -z "$NGINX_BUILD" ]; then
        print_status "Showing logs for nginx build: $NGINX_BUILD"
        oc logs build/$NGINX_BUILD
    fi
    
    if [ ! -z "$NODEJS_BUILD" ]; then
        print_status "Showing logs for nodejs build: $NODEJS_BUILD"
        oc logs build/$NODEJS_BUILD
    fi
}

# List ImageStreams
list_imagestreams() {
    print_header "Listing ImageStreams..."
    
    oc get imagestreams -o wide
    
    print_status "ImageStreams listed"
}

# Show BuildConfig details
show_buildconfig_details() {
    print_header "Showing BuildConfig details..."
    
    print_status "Dockerfile BuildConfig:"
    oc describe buildconfig nginx-dockerfile-build
    
    echo ""
    print_status "Source-to-Image BuildConfig:"
    oc describe buildconfig nodejs-s2i-build
}

# Create webhook secrets
create_webhook_secrets() {
    print_header "Creating webhook secrets..."
    
    # Create GitHub webhook secret
    oc create secret generic github-webhook-secret \
        --from-literal=WebHookSecretKey=your-github-webhook-secret \
        --dry-run=client -o yaml | oc apply -f -
    
    # Create generic webhook secret
    oc create secret generic generic-webhook-secret \
        --from-literal=WebHookSecretKey=your-generic-webhook-secret \
        --dry-run=client -o yaml | oc apply -f -
    
    print_status "Webhook secrets created"
}

# Show webhook URLs
show_webhook_urls() {
    print_header "Showing webhook URLs..."
    
    print_status "GitHub webhook URL:"
    oc describe buildconfig webhook-build | grep -A 5 "GitHub"
    
    print_status "Generic webhook URL:"
    oc describe buildconfig webhook-build | grep -A 5 "Generic"
}

# Cleanup BuildConfigs
cleanup_buildconfigs() {
    print_header "Cleaning up BuildConfigs..."
    
    read -p "Are you sure you want to delete all BuildConfigs? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Cleanup cancelled"
        return
    fi
    
    oc delete buildconfigs --all
    oc delete builds --all
    oc delete imagestreams --all
    
    print_status "BuildConfigs cleaned up"
}

# Main menu
show_menu() {
    echo ""
    echo "OpenShift BuildConfig Demo Menu:"
    echo "1. Create BuildConfigs"
    echo "2. List BuildConfigs"
    echo "3. Start builds"
    echo "4. List builds"
    echo "5. Show build logs"
    echo "6. List ImageStreams"
    echo "7. Show BuildConfig details"
    echo "8. Create webhook secrets"
    echo "9. Show webhook URLs"
    echo "10. Cleanup BuildConfigs"
    echo "11. Run full demo"
    echo "0. Exit"
    echo ""
}

# Full demo
run_full_demo() {
    print_header "Running full BuildConfig demo..."
    
    create_buildconfigs
    list_buildconfigs
    create_webhook_secrets
    show_buildconfig_details
    show_webhook_urls
    
    print_status "Full demo completed!"
    print_status "You can now manually start builds with: oc start-build <buildconfig-name>"
}

# Main function
main() {
    check_prerequisites
    
    while true; do
        show_menu
        read -p "Select an option (0-11): " choice
        
        case $choice in
            1) create_buildconfigs ;;
            2) list_buildconfigs ;;
            3) start_builds ;;
            4) list_builds ;;
            5) show_build_logs ;;
            6) list_imagestreams ;;
            7) show_buildconfig_details ;;
            8) create_webhook_secrets ;;
            9) show_webhook_urls ;;
            10) cleanup_buildconfigs ;;
            11) run_full_demo ;;
            0) print_status "Exiting..."; exit 0 ;;
            *) print_error "Invalid option. Please select 0-11." ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
