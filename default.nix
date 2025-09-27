{ pkgs ? import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/refs/heads/nixos-unstable.tar.gz";
}) {} }:

let
  nixpkgs = pkgs;
in
{
  devShell = nixpkgs.mkShell {
    buildInputs = [ nixpkgs.nixfmt nixpkgs.nixfmt-rfc-style ];

    # expose a NIL marker in the shell environment (empty string)
    shellHook = ''
      export NIL=""
      printf "dev shell: nixfmt available, NIL exposed\n"
    '';
  };

  # NixOS module to install nixfmt for all users
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.nixfmt-rfc-style ];
  };
}
