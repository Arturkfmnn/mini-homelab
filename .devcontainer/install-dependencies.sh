#!/bin/bash

apt-get update
apt-get install -y git curl gnupg lsb-release xz-utils

curl -LO https://dl.k8s.io/release/$(curl -LS https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -LO https://github.com/helmfile/helmfile/releases/latest/download/helmfile_linux_amd64
chmod +x helmfile_linux_amd64
mv helmfile_linux_amd64 /usr/local/bin/helmfile
mkdir -m 0755 /nix && chown root /nix
# Create nixbld group and users for Nix builds
export NIX_FIRST_BUILD_UID=30001
export NIX_BUILD_GROUP_ID=999
groupadd -r nixbld -g $NIX_BUILD_GROUP_ID
for i in $(seq 1 10); do
  uid=$((NIX_FIRST_BUILD_UID + i - 1))
  useradd -c "Nix build user $i" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin || echo /bin/false)" -u $uid "nixbld$i"
done
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
