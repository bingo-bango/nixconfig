{ pkgs, ... }:

{
  virtualisation.oci-containers.containers.playit = {
    image = "ghcr.io/playit-cloud/playit-agent:1.0";
    autoStart = true;
    environment = {
      SECRET_KEY = "XXXXXXXXXXX"; # Replace with your actual key
    };
    extraOptions = [
      "--net=host"
    ];
  };
}