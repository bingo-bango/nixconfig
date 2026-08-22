{
  description = "nixconfig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    vars = import ./vars.nix;

    mkNixOSConfig = path:
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs vars; };
        modules = [ path ];
      };
  in {
    nixosConfigurations = {
      playserver = mkNixOSConfig ./machines/playserver/configuration.nix;
    };
  };
}