#!/usr/bin/env bash

# Helper script to run nix commands with experimental features enabled
# Usage: ./nix-helper.sh <nix command and arguments>
# Note: For build commands, --out-link is automatically added if not specified

args=("$@")

# Check if this is a build command and add --out-link if not present
if [[ "$1" == "build" ]] && [[ "$*" != *"--out-link"* ]] && [[ "$*" != *"-o"* ]] && [[ "$*" != *"--no-link"* ]]; then
    # Extract the target name for the result symlink
    if [[ "$*" == *"nixosConfigurations."* ]]; then
        machine=$(echo "$*" | grep -o 'nixosConfigurations\.[^.]*' | cut -d. -f2)
        args=("build" "--out-link" "result-$machine" "${args[@]:1}")
    else
        # For other builds, use default result symlink (which nix creates automatically)
        args=("$@")
    fi
fi

nix --extra-experimental-features nix-command --extra-experimental-features flakes "${args[@]}"