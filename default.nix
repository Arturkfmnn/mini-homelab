{ pkgs ? import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-unstable.tar.gz";
}) {} }:

let
  nixpkgs = pkgs;
in
nixpkgs.mkShell {
  buildInputs = [ nixpkgs.nixfmt ];

  # expose a NIL marker in the shell environment (empty string)
  shellHook = ''
    export NIL=""
    printf "dev shell: nixfmt available, NIL exposed\n"
  '';
}