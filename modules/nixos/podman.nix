{ config, pkgs, vars, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Allows 'docker' CLI commands to control Podman
    defaultNetwork.settings.dns_enabled = true;
    autoPrune.enable = true;
  };

  # Grant your primary user permission to interact with Podman
  users.users.${vars.username}.extraGroups = [ "podman" ];
}