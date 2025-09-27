#!/usr/bin/env bash

# Remote deployment script for NixOS configurations
# Usage: ./deploy.sh <machine> <target-host>
# Example: ./deploy.sh hugin root@192.168.1.100

set -e

MACHINE=$1
TARGET_HOST=$2

if [ -z "$MACHINE" ] || [ -z "$TARGET_HOST" ]; then
    echo "Usage: $0 <machine> <target-host>"
    echo "Available machines: hugin, munin"
    echo "Example: $0 hugin root@192.168.1.100"
    exit 1
fi

echo "Deploying $MACHINE configuration to $TARGET_HOST..."

# Test SSH connectivity first
echo "Testing SSH connection to $TARGET_HOST..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $TARGET_HOST "echo 'SSH connection successful'"; then
    echo "❌ Cannot connect to $TARGET_HOST via SSH"
    echo "Please ensure:"
    echo "  • SSH key authentication is set up"
    echo "  • The target host is reachable"
    echo "  • SSH service is running on the target"
    exit 1
fi

echo "Building configuration locally and deploying to remote host..."

# Build locally, deploy remotely (without --build-host to avoid localhost SSH issues)
nix --extra-experimental-features nix-command --extra-experimental-features flakes \
    run nixpkgs#nixos-rebuild -- switch \
    --flake .#$MACHINE \
    --target-host $TARGET_HOST

echo "✅ Deployment of $MACHINE to $TARGET_HOST completed!"