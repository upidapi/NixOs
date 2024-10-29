{
  my_lib,
  config,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf mkDefault;
  cfg = config.modules.home.suites.all;
  enable = {
    enable = mkDefault true;
  };
  # disable = {
  #   enable = mkDefault false;
  # };
in {
  options.modules.home.suites.all =
    mkEnableOpt "enables everything except the hardware specific stuff";

  config = mkIf cfg.enable {
    modules.home = {
      other = enable;

      apps = {
        # alacritty = enable;
        kitty = enable;
        # bitwarden = enable;
        discord = enable;
        firefox = enable;
        r2modman = enable;
        spotify = enable;
        keepassxc = enable;
        vscode = enable;
        ghidra = enable;
      };

      cli-apps = {
        color-pick = enable;
        bat = enable;
        cn-bth = enable;
        eza = enable;
        git = enable;
        gpg = enable;
        nix-index = enable;
        # nixvim = enable;
        nvf = enable;
        ssh = enable;
        wine = enable;
      };

      terminal = {
        direnv = enable;
        nushell = enable;
        tmux = enable;
        zsh = {
          enable = true;
          set-shell = true;
        };
        starship = enable;
      };

      services = {
        playerctl = enable;
      };

      misc = {
        dconf = enable;
        sops = enable;
        persist = enable;
        stylix = enable;
        mime = enable;
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
          hyprcursor = enable;
        };
      };
    };
  };
}
