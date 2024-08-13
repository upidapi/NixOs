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
        # bitwarden = enable;
        discord = enable;
        firefox = enable;
        r2modman = enable;
        spotify = enable;
      };

      # TODO: probably refactor cli-apps/ into
      #  terminal/
      #    shells/
      #    extensions/
      #    tools/
      cli-apps = {
        direnv = enable;
        keepassxc = enable;
        # nixvim = enable;
        nvf = enable;
        eza = enable;
        # nushell = enable;
        tmux = enable;
        bat = enable;
        gpg = enable;
        cn-bth = enable;
        zsh = {
          enable = true;
          set-shell = true;
        };
        wine = enable;
        git = enable;
        ssh = enable;
        nix-index = enable;
      };

      services = {
        playerctl = enable;
      };

      misc = {
        dconf = enable;
        sops = enable;
        persist = enable;
      };

      desktop = {
        wayland = enable;
        hyprland = enable;
        addons = {
          wallpaper.hyprpaper = enable;
          bar.ags = enable;
          dunst = enable;
          gtk = enable;
          rofi = enable;
          hyprlock = enable;
          hypridle = enable;
        };
      };
    };
  };
}
