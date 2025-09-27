#!/usr/bin/env bash

# Helper script to run nix commands with experimental features enabled
# Usage: ./nix-helper.sh <nix command and arguments>

nix --extra-experimental-features nix-command --extra-experimental-features flakes "$@"