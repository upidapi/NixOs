{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.environment.xdg;
in {
  options.modules.nixos.os.environment.xdg = mkEnableOpt "default app stuff";

  config = mkIf cfg.enable {
    environment = {
      sessionVariables = {
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_BIN_HOME = "$HOME/.local/bin";
        # To prevent firefox from creating ~/Desktop.
        XDG_DESKTOP_DIR = "$HOME";
      };
      variables = {
        # Make some programs "XDG" compliant.
        LESSHISTFILE = "$XDG_CACHE_HOME/less.history";
        WGETRC = "$XDG_CONFIG_HOME/wgetrc";
      };
    };

    # /etc/profiles/per-user/$(whoami)/share/applications/
    /*
    # TODO: do some xdg stuff
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
