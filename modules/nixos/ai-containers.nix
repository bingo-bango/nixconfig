{ config, pkgs, ... }:

{
  # 1. Firewall rules

  networking.firewall.allowedTCPPorts = [
    11434 # Ollama
    7860  # AUTOMATIC1111 WebUI
  ];

  # 2. OCI Container Definitions managed by Systemd
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      
      # Ollama Container (CPU-Optimized)
      ollama = {
        image = "ollama/ollama:latest";
        autoStart = true;
        ports = [ "0.0.0.0:11434:11434" ];
        volumes = [
          "/var/lib/ai-models/ollama:/root/.ollama"
        ];
        environment = {
          "OLLAMA_HOST" = "0.0.0.0";
          "OLLAMA_NUM_PARALLEL" = "1";
        };
      };

      # AUTOMATIC1111 WebUI Container
      sd-webui = {
        image = "universaldot/stable-diffusion-webui:latest";
        autoStart = false; # Set to false to conserve RAM on boot
        ports = [ "0.0.0.0:7860:7860" ];
        volumes = [
          "/var/lib/ai-models/sd-webui/models:/app/models"
          "/var/lib/ai-models/sd-webui/outputs:/app/outputs"
        ];
        cmd = [ "--use-cpu", "all", "--no-half", "--precision", "full", "--listen" ];
      };

    };
  };
}