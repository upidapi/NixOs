{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.misc.mime;
in {
  options.modules.home.misc.mime = mkEnableOpt "default app stuff";

  # .desktop files all seem to be located at
  # /etc/profiles/per-user/upidapi/share/applications/

  config = let
    editor = ["nvim.desktop"];
    browser = ["zen-beta.desktop"];
    mailer = ["thunderbird.desktop"];
    fileManager = ["org.kde.dolphin.desktop"];
    terminal = ["kitty.desktop"];

    associations = {
      "text/plain" = editor;

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
      "video/*" = ["vlc.desktop"];
      "image/*" = ["gwenview.desktop"];

      "application/json" = browser; # change this?
      "application/pdf" = browser;

      "x-scheme-handler/tg" = ["telegramdesktop.desktop"];
      "x-scheme-handler/spotify" = ["spotify.desktop"];
      "x-scheme-handler/discord" = ["vesktop.desktop"];
      "x-scheme-handler/mailto" = mailer;
    };
  in
    mkIf cfg.enable {
      /*
      change what terminal xdg-run uses

      https://discourse.gnome.org/t/open-in-terminal-choose-which-terminal-application-to-open/15512/4

      Basically what terminal is uses is hard coded, however
      the one with the ighest prio is xdg-terminal-exec and
      that one runs the first working one in xdg-terminals.list
      */
      home.packages = with pkgs; [
        xdg-terminal-exec
      ];

      xdg = {
        enable = true;

        configFile."xdg-terminals.list".text = ''
          ${builtins.elemAt terminal 0}
        '';

        mimeApps = {
          enable = true;
          associations.added = associations;
          defaultApplications = associations;
        };
      };
    };
}
