{
  description = "Homelab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # Disko for disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs: let
    # Define your machines here
    machines = [
      "hugin"
      "munin"
    ];
  in {
    nixosConfigurations = builtins.listToAttrs (map (name: {
      name = name;
      value = nixpkgs.lib.nixosSystem {
        specialArgs = {
          meta = { hostname = name; };
        };
        system = "x86_64-linux";
        modules = [
          # Modules
          disko.nixosModules.disko
          ./machines/${name}/hardware-configuration.nix
          ./machines/${name}/configuration.nix
          # Add disko-config if it exists for the machine
        ] ++ (if builtins.pathExists ./machines/${name}/disko-config.nix
              then [ ./machines/${name}/disko-config.nix ]
              else []);
      };
    }) machines);
  };
}
