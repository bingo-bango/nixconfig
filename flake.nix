{
  description = "nixconfig";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, sops-nix, ... }@inputs: let
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