{ config, pkgs, ... }:

{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.crafty = {
    image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
    autoStart = true;
    extraOptions = [
      "--ip=10.88.0.50"   # Assigns a fixed static IP inside the Podman network
    ];
    ports = [
      "8443:8443"          # Web GUI
      "25500:25500/udp"    # Papas Game Port IPv4
      "25501:25501/udp"    # Papas Game Port IPv6
      "25502:25502/udp"    # Paulo Game Port IPv4
      "25503:25503/udp"    # Paulo Game Port IPv6
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