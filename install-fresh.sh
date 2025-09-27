#!/usr/bin/env bash

# Fresh installation script using nixos-anywhere
# Usage: ./install-fresh.sh <machine> <target-host>
# WARNING: This will wipe the target machine!

set -e

MACHINE=$1
TARGET_HOST=$2

if [ -z "$MACHINE" ] || [ -z "$TARGET_HOST" ]; then
    echo "Usage: $0 <machine> <target-host>"
    echo "Available machines: hugin, munin"
    echo "Example: $0 hugin root@192.168.1.100"
    echo ""
    echo "⚠️  WARNING: This will completely wipe the target machine!"
    exit 1
fi

echo "⚠️  WARNING: This will completely wipe $TARGET_HOST and install $MACHINE configuration!"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Installation cancelled."
    exit 1
fi

echo "Installing $MACHINE configuration on $TARGET_HOST..."

# Use nixos-anywhere for fresh installation
nix --extra-experimental-features nix-command --extra-experimental-features flakes \
    run github:nix-community/nixos-anywhere -- \
    --flake .#$MACHINE \
    $TARGET_HOST

echo "✅ Fresh installation of $MACHINE on $TARGET_HOST completed!"