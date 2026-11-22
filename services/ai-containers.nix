{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    11434 # Ollama
    7860  # AUTOMATIC1111
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/ai-models 0755 root root -"
    "d /var/lib/ai-models/ollama 0755 root root -"
    "d /var/lib/ai-models/sd-webui 0755 root root -"
    "d /var/lib/ai-models/sd-webui/models 0775 10000 root -"
    "d /var/lib/ai-models/sd-webui/outputs 0775 10000 root -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      ollama = {
        image = "ollama/ollama:latest";
        autoStart = true;
        ports = [ "0.0.0.0:11434:11434" ];
        volumes = [ "/var/lib/ai-models/ollama:/root/.ollama" ];
        environment = {
          OLLAMA_HOST = "0.0.0.0";
          OLLAMA_NUM_PARALLEL = "1";
        };
      };

      sd-webui = {
        image = "siutin/stable-diffusion-webui-docker:latest-cpu";
        autoStart = false;  # keep false if you want to start it manually to save RAM
        ports = [ "0.0.0.0:7860:7860" ];
        volumes = [
          "/var/lib/ai-models/sd-webui/models:/app/stable-diffusion-webui/models"
          "/var/lib/ai-models/sd-webui/outputs:/app/stable-diffusion-webui/outputs"
        ];
        # The image expects webui.sh as the entrypoint
        cmd = [
          "bash" "webui.sh"
          "--skip-torch-cuda-test"
          "--use-cpu" "all"
          "--no-half"
          "--precision" "full"
          "--listen"
          "--api"
        ];
        # Optional: if you later want GPU, remove the CPU flags above and add:
        # extraOptions = [ "--device" "nvidia.com/gpu=all" "--security-opt" "label=disable" ];
      };
    };
  };
}