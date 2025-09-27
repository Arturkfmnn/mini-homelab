# Homelab

Base configuration from [Dreams of Autonomy - homelab](https://github.com/dreamsofautonomy/homelab).

But realized, for now I don't need a k8s cluster.

This project is split into different directories depending on each service used.

## Requirements

To use this, you'll need the following installed on your sysetm

- nix
- kubectl
- helmfile
- helm
- git

Additionally, you'll also want to make changes to the user information found in the `nixos/configuration.nix`

Provided by devcontainers if used.

## nixos

This directory contains the nixos configuration for setting
up each node with k3s.

The configuration makes use of nix flakes under the hood, with each node configuration being:

```
hugin
munin
```

To set up a node from fresh, you can use [nixos-anywhere](https://github.com/nix-community/nixos-anywhere). This requires loading the nixos installer and then booting the node into it. You can then install remotely once you've set the nodes password using the `passwd` command.

The command I use is as follows:

```shell
# Show all available configurations
./nix-helper.sh flake show

# Build a specific machine configuration
./nix-helper.sh build .#nixosConfigurations.hugin.config.system.build.toplevel
./nix-helper.sh build .#nixosConfigurations.munin.config.system.build.toplevel

# Check flake for errors
./nix-helper.sh flake check

# Update flake inputs (nixpkgs, disko, etc.)
./nix-helper.sh flake update

# Deploy to a machine (when you're on the target machine)
sudo nixos-rebuild switch --flake .#hugin
sudo nixos-rebuild switch --flake .#munin

# Build installation ISO (if needed)
./nix-helper.sh build .#nixosConfigurations.hugin.config.system.build.isoImage

# Deploy configuration
./deploy.sh hugin root@192.168.50.210

```

# Quick Workflow Tips

Before deploying: Always run .[nix-helper.sh](http://_vscodecontentref_/2) flake check to catch configuration errors

Testing changes: Use .[nix-helper.sh](http://_vscodecontentref_/3) build .#nixosConfigurations.<machine>.config.system.build.toplevel to test without deploying

Keep updated: Periodically run .[nix-helper.sh](http://_vscodecontentref_/4) flake update to get the latest packages

# k8s stuff

<details>

## helm

This directory is used to store the helm configuration of the node and is managed using [helmfile](https://github.com/helmfile/helmfile), which is a declarative spec for defining helm charts.

To install this on your cluster, you can simply use the following command.

```
helmfile apply
```


## kustomize

Kustomize allows you to manage multiple manifest files in a `Kustomize.yaml`, which also allows you to override values if you need to.

I don't use Kustomize that much in the video, but it's a tool I do often use and is available in `kubectl`.

</details>