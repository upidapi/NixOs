{
  mlib,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (mlib) mkEnableOpt enableAnd;
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
        bitwarden = enable;
        discord = enable;
        firefox = enable;
        r2modman = enable;
        spotify = enable;
        keepassxc = enable;
        # vscode = enable; # broken
        obsidian = enable;
        ghidra = enable;
      };

      cli-apps = {
        color-pick = enable;
        pastebin = enable;
        bat = enable;
        bt-dualboot = enable;
        cn-phone = enable;
        cn-bth = enableAnd {
          deviceAddr = "AC:80:0A:39:DD:C4 ";
        };
        eza = enable;
        btop = enable;
        git = enable;
        gh = enable;
        gpg = enable;
        nix-index = enable;
        # nixvim = enable;
        neovim = enable;
        ssh = enable;
        wine = enable;
        zoxide = enable;
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
        sops = enable;
        persist = enable;
        stylix = enable;
        mime = enable;
        keyd = enable;
      };

      desktop = {
        wayland = enable;
        gtk = enable;

        hyprland = enable;
        hyprlock = enable;
        hypridle = enable;
        # hyprcursor = enable; # i used stylix instead

        wallpaper.hyprpaper = enable;
        bar.ags = enable;
        dunst = enable;
        rofi = enable;
      };
    };
  };
}
