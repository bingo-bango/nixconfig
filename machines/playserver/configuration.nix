{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/podman.nix
    ../../services/crafty.nix
    ../../services/playit.nix
  ];

  networking.hostName = "playserver";

  system.stateVersion = "26.05";
}