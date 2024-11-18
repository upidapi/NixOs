{
  my_lib,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enableAnd;
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
        cn-bth = enableAnd {
          deviceAddr = "AC:80:0A:2E:81:6A";
        };
        eza = enable;
        git = enable;
        gpg = enable;
        nix-index = enable;
        # nixvim = enable;
        nvf = enable;
        ssh = enable;
        wine = enable;
        # might enable if i manage to get better completions
        # zoxide = enable;
      };

      terminal = {
        defaultShell = pkgs.nushell;

        nushell = enable;
        zsh = enable;

        direnv = enable;
        tmux = enable;
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
