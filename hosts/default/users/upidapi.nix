{
  # pkgs,
  # inputs,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  # Dont change this unless you reinsall from scratch.
  home.stateVersion = "23.11"; # Read comment

  # test

  modules.home = {
    other = enable;

    apps = {
      alacritty = enable;
      bitwarden = enable;
      discord = enable;
      firefox = enable;
      r2modman = enable;
    };

    cli-apps = {
      nixvim = enable;
      # nushell = enable;
      zsh = {
        enable = true;
        set-shell = true;
      };
      wine = enable;
      git = enable;
    };

    core = {
      persist = enable;
    };

    desktop = {
      wayland = enable;
      hyprland = enable;
      addons = {
        swww = enable;
        dunst = enable;
        gtk = enable;
        rofi = enable;
        waybar = enable;
      };
    };

    scripts = {
      # regen-nixos = enable;
      cn-bth = enable;
      qs = enable;
    };
  };
}
