{ inputs, vars, config, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs vars;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      ${vars.userName} = {
        imports = [
          # ./../../modules/home-manager/alacritty.nix
          ./../../modules/home-manager/base.nix
          # ./../../modules/home-manager/desktop.nix
          # ./../../modules/home-manager/fonts.nix
          # ./../../modules/home-manager/git.nix
        ];
      };
    };
  };

  networking.hostName = "think";

  system.stateVersion = "26.05";
}