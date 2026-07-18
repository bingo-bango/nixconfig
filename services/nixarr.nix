{
  config,
  lib,
  pkgs,
  vars,
  ...
}: let
  renderDevice = "/dev/dri/renderD128";
in {
  imports = [
    ./acme.nix
    ./nginx.nix
  ];

  sops = {
    secrets = {
      "cloudflare-tunnel-01" = {
        format = "binary";
        sopsFile = ./../secrets/cloudflare-tunnel-01;
      };
      "cloudflare-cert" = {
        format = "binary";
        sopsFile = ./../secrets/cloudflare-cert.pem;
      };
      "wg.conf" = {
        format = "binary";
        sopsFile = ./../secrets/wg.conf;
      };
    };
  };

  environment.etc."cloudflared/cert.pem".source = config.sops.secrets."cloudflare-cert".path;

  nixarr = {
    enable = true;
    mediaDir = "/fun";
    stateDir = "/var/lib/nixarr";

    jellyfin.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    sonarr.enable = true;

    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      # todo: figure out how to update this easier
      peerPort = 46634;
      vpn.enable = true;
      extraSettings = {
        peer-limit-global = 200;
        cache-size-mb = 256;
        incomplete-dir = "/var/lib/transmission/.incomplete";
        incomplete-dir-enabled = true;
        download-queue-enabled = true;
        download-queue-size = 20;
        speed-limit-up = 500;
        speed-limit-up-enabled = true;
        rpc-authentication-required = true;
        rpc-username = vars.userName;
        rpc-whitelist-enabled = false;
        # todo: figure out how to integrate rpc-password into sops-nix
        rpc-password = "{7d827abfb09b77e45fe9e72d97956ab8fb53acafoPNV1MpJ";
      };
    };

    vpn = {
      enable = true;
      wgConf = config.sops.secrets."wg.conf".path;
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };

  services.jellyfin = {
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = renderDevice;
    };
    transcoding = {
      enableHardwareEncoding = true;
      enableToneMapping = true;
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        mpeg2 = true;
        vc1 = true;
        vp8 = true;
        vp9 = true;
      };
      hardwareEncodingCodecs.hevc = true;
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "chenglab-01" = {
        credentialsFile = config.sops.secrets."cloudflare-tunnel-01".path;
        default = "http_status:404";
        ingress = {
          "watch.${vars.domain}" = {
            service = "http://localhost:${toString config.nixarr.jellyfin.port}";
          };
        };
      };
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
      intel-media-driver
      libvdpau-va-gl
      intel-vaapi-driver
      libva-vdpau-driver
    ];
  };

  environment.systemPackages = with pkgs; [
    # To enable `intel_gpu_top`
    intel-gpu-tools
    # because nixarr does not include it by default
    wireguard-tools
  ];

  services.nginx = {
    virtualHosts = {
      "watch.${vars.domain}" = {
        forceSSL = true;
        useACMEHost = vars.domain;
        locations."/" = {
          recommendedProxySettings = true;
          proxyWebsockets = true;
          proxyPass = "http://127.0.0.1:${toString config.nixarr.jellyfin.port}";
          extraConfig = ''
            proxy_buffering off;
          '';
        };
      };

      "prowlarr.${vars.domain}" = {
        forceSSL = true;
        useACMEHost = vars.domain;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:${toString config.nixarr.prowlarr.port}";
        };
      };

      "radarr.${vars.domain}" = {
        forceSSL = true;
        useACMEHost = vars.domain;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:${toString config.nixarr.radarr.port}";
        };
      };

      "sonarr.${vars.domain}" = {
        forceSSL = true;
        useACMEHost = vars.domain;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:${toString config.nixarr.sonarr.port}";
        };
      };

      "transmission.${vars.domain}" = {
        forceSSL = true;
        useACMEHost = vars.domain;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.nixarr.transmission.uiPort}";
        };
      };
    };
  };

  systemd = {
    services = {
      "cloudflared-route-tunnel" = {
        description = "Point traffic to tunnel subdomain";
        after = [
          "network-online.target"
          "cloudflared-tunnel-chenglab-01.service"
        ];
        wants = [
          "network-online.target"
          "cloudflared-tunnel-chenglab-01.service"
        ];
        wantedBy = ["default.target"];
        serviceConfig = {
          Type = "oneshot";
          # workaround to ensure dns is available before setting up cloudflare tunnel
          # inspo: chatgpt
          ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in {1..10}; do ${pkgs.iputils}/bin/ping -c1 api.cloudflare.com && exit 0 || sleep 3; done; exit 1'";
          ExecStart = "${lib.getExe pkgs.cloudflared} tunnel route dns --overwrite-dns 'Chenglab-01' 'watch.${vars.domain}'";
        };
      };
    };

    tmpfiles.rules = ["d /var/lib/nixarr 0755 root root"];
  };

  chenglab.kopiaBackup.paths = ["/var/lib/nixarr"];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/nixarr"
      "/var/lib/transmission/.incomplete"
    ];
  };
}
