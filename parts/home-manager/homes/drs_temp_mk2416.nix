{
  pkgs,
  config,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  home = {
    stateVersion = "23.11";

    homeDirectory = "/mnt/${config.home.username}";

    activation.swapEscape = ''
      setxkbmap -option caps:swapescape
    '';
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      # "steam"
      # "steam-run"
      # "steam-original"
    ];

  fonts.fontconfig.enable = true;

  modules.home = {
    other = enable;

    apps = {
      alacritty = enable;
      bitwarden = enable;
      discord = enable;
      firefox = enable;
      r2modman = enable;
      spotify = enable;
    };

    cli-apps = {
      nixvim = enable;
      # nushell = enable;
      tmux = enable;
      zsh = {
        enable = true;
        set-shell = true;
      };
      wine = enable;
      git = enable;
      bat = enable;
      cn-bth = enable;
    };

    services = {
      playerctl = enable;
    };

    misc = {
      dconf = enable;
      sops = enable;
      # persist = enable;
    };

    desktop = {
      wayland = enable;
      hyprland = enable;
      addons = {
        swww = enable;
        # eww = enable;
        ags = enable;
        dunst = enable;
        gtk = enable;
        rofi = enable;
        waybar = enable;
      };
    };
  };
}
