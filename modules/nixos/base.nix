{
  inputs,
  config,
  pkgs,
  vars,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops  # Disabled for now; re-enable when setting up sops
    # ./kopia-backup.nix                 # Uncomment if you have this file in modules/nixos/
    # ./packages.nix                     # Uncomment if you have this file in modules/nixos/
  ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    efi.canTouchEfiVariables = true;
    timeout = 10;
  };

  nixpkgs.config.allowUnfree = true;
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  sops = {
    defaultSopsFile = ./../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/nix/secret/ssh_host_ed25519_key"];
    # secrets."user-password".neededForUsers = true;
    # secrets."user-password" = {};
    # inspo: https://github.com/Mic92/sops-nix/issues/427
    gnupg.sshKeyPaths = [];
  };

  # Standard mutable user management without sops password files
  users.mutableUsers = true;
  users.users.${vars.userName} = {
    isNormalUser = true;
    description = vars.userName;
    extraGroups = [ "networkmanager" "wheel" "podman" ];
    openssh.authorizedKeys.keys = [
      vars.sshPublicKeyPersonal
    ];
    shell = pkgs.zsh;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true; # Set to false once your SSH key is confirmed working
      };
      openFirewall = true;
    };
    fstrim.enable = true;
  };

  networking = {
    firewall.enable = true;
    networkmanager.enable = true;
  };

  # Fix NetworkManager wait online delay on boot
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = ["" "${pkgs.networkmanager}/bin/nm-online -q"];
    };
  };

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  time.timeZone = vars.timeZone;
  zramSwap.enable = true;

  # Base packages installed across all machines
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    just
    htop
  ];
}