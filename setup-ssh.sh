#!/usr/bin/env bash

# SSH troubleshooting and setup helper
# Usage: ./setup-ssh.sh <target-host>

TARGET_HOST=$1

if [ -z "$TARGET_HOST" ]; then
    echo "Usage: $0 <target-host>"
    echo "Example: $0 root@192.168.50.210"
    exit 1
fi

echo "🔧 SSH Setup and Troubleshooting for $TARGET_HOST"
echo "================================================"
echo ""

# Check if SSH keys exist
echo "1️⃣ Checking for SSH keys..."
if [ -f ~/.ssh/id_rsa ] || [ -f ~/.ssh/id_ed25519 ]; then
    echo "✅ SSH keys found:"
    ls -la ~/.ssh/id_* 2>/dev/null || echo "No private keys found"
    echo ""
else
    echo "❌ No SSH keys found. Generating new ED25519 key..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    echo "✅ New SSH key generated!"
    echo ""
fi

# Show public key
echo "2️⃣ Your public key (copy this to target host):"
echo "================================================"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    cat ~/.ssh/id_ed25519.pub
elif [ -f ~/.ssh/id_rsa.pub ]; then
    cat ~/.ssh/id_rsa.pub
else
    echo "❌ No public key found"
fi
echo ""

# Test connectivity
echo "3️⃣ Testing basic connectivity..."
if ping -c 1 -W 5 $(echo $TARGET_HOST | cut -d@ -f2) >/dev/null 2>&1; then
    echo "✅ Host is reachable via ping"
else
    echo "❌ Host is not reachable via ping"
fi
echo ""

echo "4️⃣ Testing SSH connection..."
ssh -o ConnectTimeout=10 -o BatchMode=yes $TARGET_HOST "echo 'SSH connection successful'" 2>&1

echo ""
echo "📋 Manual Setup Steps:"
echo "====================="
echo "If SSH connection failed, you need to:"
echo ""
echo "1. Copy your public key to the target host:"
echo "   ssh-copy-id $TARGET_HOST"
echo "   OR manually add the public key above to ~/.ssh/authorized_keys on the target"
echo ""
echo "2. Ensure SSH service is running on target:"
echo "   systemctl status sshd"
echo ""
echo "3. Check SSH configuration allows key authentication:"
echo "   grep -E 'PubkeyAuthentication|PasswordAuthentication' /etc/ssh/sshd_config"
echo ""
echo "4. Test manual SSH connection:"
echo "   ssh $TARGET_HOST"