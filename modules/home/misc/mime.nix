{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.misc.mime;
in {
  options.modules.home.misc.mime = mkEnableOpt "default app stuff";

  config = mkIf cfg.enable {
    # make xdg run use alacritty

    /*
    xterm

    if you run xterm from rofi you get the white terminal that
    xdg-open seams to use

    xdg-open /persist/nixos/flake.nix

    e /etc/profiles/per-user/upidapi/share/applications/
    */

    home.packages = with pkgs; [
      xdg-terminal-exec
    ];

    xdg.configFile."xdg-terminals.list".text = ''
      ${"alacritty.desktop"}
    '';

    # /etc/profiles/per-user/$(whoami)/share/applications/
    /*
    # TODO: implement this (mime stuff)
    xdg = let
      browser = ["Schizofox.desktop"];
      mailer = ["thunderbird.desktop"];
      zathura = ["zathura.desktop"];
      fileManager = ["org.kde.dolphin.desktop"];

      associations = {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/ftp" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;

        "inode/directory" = fileManager;
        "application/x-xz-compressed-tar" = ["org.kde.ark.desktop"];

        "audio/*" = ["mpv.desktop"];
        "video/*" = ["mpv.desktop"];
        "image/*" = ["imv.desktop"];
        "application/json" = browser;
        "application/pdf" = zathura;

        "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
        "x-scheme-handler/spotify" = ["spotify.desktop"];
        "x-scheme-handler/discord" = ["WebCord.desktop"];
        "x-scheme-handler/mailto" = mailer;
      };
    in {
      enable = true;

      mimeApps = {
        enable = true;
        associations.added = associations;
        defaultApplications = associations;
      };
    };
    */
  };
}
