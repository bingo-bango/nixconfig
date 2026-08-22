{ config, pkgs, ... }:

{
  # 1. Define the secret and render it into an environment file
  sops = {
    secrets.playit_secret_key = {};
    templates."playit.env".content = ''
      SECRET_KEY=${config.sops.placeholder.playit_secret_key}
    '';
  };

  # 2. Configure the Podman container to load the rendered env file
  virtualisation.oci-containers.containers.playit = {
    image = "ghcr.io/playit-cloud/playit-agent:1.0";
    autoStart = true;
    environmentFiles = [
      config.sops.templates."playit.env".path
    ];
    extraOptions = [
      "--net=host"
    ];
  };
}