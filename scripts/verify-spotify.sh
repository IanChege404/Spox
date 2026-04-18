#!/bin/bash

# Spotify Configuration Validator
# 
# This script validates your Spotify API credentials by:
# 1. Checking all required environment variables are present
# 2. Validating their format
# 3. Testing authentication with Spotify API
#
# Usage:
#   ./scripts/verify-spotify.sh
#   or
#   bash scripts/verify-spotify.sh

set -e

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Logging functions
log_error() {
    echo -e "${RED}✗ ERROR:${NC} $@"
}

log_success() {
    echo -e "${GREEN}✓${NC} $@"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $@"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $@"
}

log_debug() {
    echo -e "${GRAY}  $@${NC}"
}

# Check if Node.js is installed
check_nodejs() {
    if ! command -v node &> /dev/null; then
        log_error "Node.js is required but not installed"
        echo "Please install Node.js from https://nodejs.org/"
        exit 1
    fi
    log_success "Node.js is installed ($(node --version))"
}

# Check if .env exists
check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        log_error ".env file not found at $ENV_FILE"
        exit 1
    fi
    log_success ".env file found"
}

# Extract value from .env file
get_env_value() {
    local key=$1
    grep "^${key}=" "$ENV_FILE" | cut -d'=' -f2- || echo ""
}

# Main validation
main() {
    echo ""
    log_info "Starting Spotify Configuration Validation"
    echo ""
    
    # Check prerequisites
    log_info "Checking prerequisites..."
    check_nodejs
    check_env_file
    echo ""
    
    # Run Node.js validation
    log_info "Running detailed validation script..."
    echo ""
    
    if [ -f "$SCRIPT_DIR/validate-spotify-config.js" ]; then
        node "$SCRIPT_DIR/validate-spotify-config.js"
    else
        log_error "validate-spotify-config.js not found"
        exit 1
    fi
}

# Run main function
main "$@"
