{
  my_lib,
  config,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.home.suites.all;
in {
  options.modules.home.suites.all =
    mkEnableOpt "enables everything except the hardware specific stuff";

  # TODO: split this into smaller parts
  # TODO: dont just enable it but use something like mkDefault
  #  so that a user can override a suite

  config = mkIf cfg.enable {
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
      };

      tools = {
        playerctl = enable;
      };

      core = {
        persist = enable;
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

      scripts = {
        # regen-nixos = enable;
        cn-bth = enable;
      };
    };
  };
}
