{
  lib,
  pkgs,
  vars,
  ...
}: {
  imports = [
    ./packages.nix
    ./zsh.nix
  ];

  home = {
    username = vars.userName;
    homeDirectory = "/home/${vars.userName}";
    stateVersion = "26.05";
  };

  programs = {
    # helix = {
    #   enable = true;
    #   defaultEditor = true;
    #   settings = {
    #     theme = "dark_high_contrast";
    #   };
    # };
    fzf = {               # fuzzy finder
      enable = true;
      enableZshIntegration = true;
    };
    zellij = {
      enable = true;
      settings = {
        theme = "dracula";
      };
    };
    tealdeer = {            # man pages
      enable = true;
      settings.updates.auto_update = true;
    };
    direnv = {
      # note: figure out way to re-enable this later
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    # asciinema.enable = true;
    bat.enable = true;        # like cat but with syntax highlighting
    btop.enable = true;       # resource monitor
    # gallery-dl.enable = true;
    fastfetch.enable = true;  # fetches system info
    htop.enable = true;       # resource monitor
    # jq.enable = true;
    lsd.enable = true;        # rewrite of GNU ls with lots of added features
    nh.enable = true;         # nix helper util
    # pandoc.enable = true;
    # vim.enable = true;
    yt-dlp.enable = true;
    ripgrep.enable = true;    # regex grep
    fd.enable = true;         # find alternative
  };

  systemd.user.startServices = "sd-switch";
}
