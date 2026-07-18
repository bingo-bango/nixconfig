{
  config,
  lib,
  pkgs,
  vars,
  ...
}: {
  sops.secrets = {
    "cloudflare-tunnel-02" = {
      format = "binary";
      sopsFile = ./../secrets/cloudflare-tunnel-02;
    };
    "cloudflare-cert" = {
      format = "binary";
      sopsFile = ./../secrets/cloudflare-cert.pem;
    };
  };

  environment.etc."cloudflared/cert.pem".source = config.sops.secrets."cloudflare-cert".path;

  services.cloudflared = {
    enable = true;
    tunnels = {
      "chenglab-02" = {
        credentialsFile = config.sops.secrets."cloudflare-tunnel-02".path;
        default = "http_status:404";
        ingress = {
          "pocketbase.${vars.domain}" = {
            service = "http://127.0.0.1:8090";
          };
        };
      };
    };
  };

  users = {
    groups.pocketbase = {};
    users.pocketbase = {
      isSystemUser = true;
      group = "pocketbase";
    };
  };

  systemd.services = {
    pocketbase = {
      description = "Pocketbase";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        User = "pocketbase";
        Group = "pocketbase";
        StateDirectory = "pocketbase";
        StateDirectoryMode = "0750";
        WorkingDirectory = "/var/lib/pocketbase";
        ExecStart = "${lib.getExe pkgs.pocketbase} serve --http=127.0.0.1:8090 --dir=/var/lib/pocketbase/pb_data --migrationsDir=/var/lib/pocketbase/pb_migrations";
        Restart = "always";
        RestartSec = "5s";
        LimitNOFILE = 4096;

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictSUIDSGID = true;
      };
    };

    cloudflared-route-pocketbase = {
      description = "Point PocketBase traffic to the Cloudflare tunnel";
      after = [
        "network-online.target"
        "cloudflared-tunnel-chenglab-02.service"
      ];
      wants = [
        "network-online.target"
        "cloudflared-tunnel-chenglab-02.service"
      ];
      wantedBy = ["default.target"];
      serviceConfig = {
        Type = "oneshot";
        # Work around DNS sometimes being unavailable when the tunnel first starts.
        ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in {1..10}; do ${pkgs.iputils}/bin/ping -c1 api.cloudflare.com && exit 0 || sleep 3; done; exit 1'";
        ExecStart = "${lib.getExe pkgs.cloudflared} tunnel route dns --overwrite-dns 'Chenglab-02' 'pocketbase.${vars.domain}'";
      };
    };
  };

  chenglab.kopiaBackup.paths = ["/var/lib/pocketbase"];

  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/pocketbase";
      user = "pocketbase";
      group = "pocketbase";
      mode = "0750";
    }
  ];
}
