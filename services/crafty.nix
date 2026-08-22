{ config, pkgs, ... }:

{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.crafty = {
    image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
    autoStart = true;
    ports = [
      "8443:8443"          # Web GUI
      "25500:25500/udp"    # Papas Game Port
      "19132:19132/udp"    # Pauls Game Port
    ];
    volumes = [
      "/var/lib/crafty/config:/crafty/app/config"
      "/var/lib/crafty/servers:/crafty/servers" # Persistent world storage
      "/var/lib/crafty/backups:/crafty/app/config/backups"
      "/var/lib/crafty/logs:/crafty/app/config/logs"
    ];
    environment = {
      TZ = "Europe/Paris";
    };
  };
}