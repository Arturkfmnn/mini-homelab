#!/usr/bin/env bash

# Alternative deployment script - builds locally, copies and activates remotely
# Usage: ./deploy-local-build.sh <machine> <target-host>

set -e

MACHINE=$1
TARGET_HOST=$2

if [ -z "$MACHINE" ] || [ -z "$TARGET_HOST" ]; then
    echo "Usage: $0 <machine> <target-host>"
    echo "Available machines: hugin, munin"
    echo "Example: $0 hugin root@192.168.1.100"
    exit 1
fi

echo "Building $MACHINE configuration locally..."

# Build the system configuration locally
RESULT=$(nix --extra-experimental-features nix-command --extra-experimental-features flakes \
    build .#nixosConfigurations.$MACHINE.config.system.build.toplevel --print-out-paths)

echo "Built system: $RESULT"

echo "Testing SSH connection to $TARGET_HOST..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $TARGET_HOST "echo 'SSH connection successful'"; then
    echo "❌ Cannot connect to $TARGET_HOST via SSH"
    exit 1
fi

echo "Copying system configuration to target host..."

# Copy the built system to the target
nix --extra-experimental-features nix-command --extra-experimental-features flakes \
    copy --to ssh://$TARGET_HOST $RESULT

echo "Activating configuration on $TARGET_HOST..."

# Activate the configuration on the remote host
ssh $TARGET_HOST "sudo nix-env --profile /nix/var/nix/profiles/system --set $RESULT && sudo $RESULT/bin/switch-to-configuration switch"

echo "✅ Deployment of $MACHINE to $TARGET_HOST completed!"