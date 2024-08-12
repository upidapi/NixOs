# this is s̶t̶o̶l̶e̶n based on https://github.com/spikespaz/dotfiles/blob/a8f39cbf196e56628d24e406aa2d2bb4c55d19a9/hm-modules/keepassxc.nix
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types;

  service = config.services.keepassxc;
  program = config.programs.keepassxc;

  iniFormat = pkgs.formats.ini {};
in {
  options = {
    services.keepassxc = {
      enable = lib.mkEnableOption "KeePassXC Service";

      package = lib.mkOption {
        type = types.package;
        description = ''
          Uses the program configuration's package by default.
        '';
        defaultText = ''
          {option}`config.programs.keepassxc.package`
        '';
      };
    };

    programs.keepassxc = {
      enable = lib.mkEnableOption ''
        Whether to install KeePassXC.
      '';

      package = lib.mkPackageOption pkgs "keepassxc" {};

      defaultDatabase = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Sets the initall opend database
          Warning: this will override the state/cache of keepass
        '';
      };

      settings = lib.mkOption {
        type = iniFormat.type;
        default = {};
        description = ''
          Settings to write in INI format to {file}`~/.config/keepassxc/keepassxc.ini`.
        '';
      };

      browserIntegration.firefox = lib.mkEnableOption ''
        Create the native messaging manifest in {path}`$HOME/.mozilla/native-messaging-hosts`,
        required for integration with the browser extension.

        Enabling this option is required if you use declarative {option}`settings`.

        Note that this also requires `Browser.Enabled = true` in {option}`settings`,
        or enable it via the GUI.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf program.enable {home.packages = [program.package];})

    (lib.mkIf
      (program.enable && (program.defaultDatabase != null))
      {
        # set the initiall db
        modules.home.standAloneFile.".cache/keepassxc/keepassxc.ini".text = (lib.generators.toINIWithGlobalSection {}) {
          globalSection = {};
          sections = {
            General = let
              db = program.defaultDatabase;
            in {
              # only one of thease are actually needed from what i know
              LastDatabases = db;
              LastActiveDatabase = db;
              LastOpenedDatabases = db;
            };
          };
        };
      })

    {services.keepassxc.package = lib.mkDefault program.package;}

    (lib.mkIf (program.enable && program.settings != {}) {
      xdg.configFile."keepassxc/keepassxc.ini".source =
        iniFormat.generate "keepassxc.ini" program.settings;
    })

    (lib.mkIf ((program.enable || service.enable)
      && program.browserIntegration.firefox) {
      modules.home.standAloneFile.".mozilla/native-messaging-hosts/org.keepassxc.keepassxc_browser.json".text = builtins.toJSON {
        allowed_extensions = ["keepassxc-browser@keepassxc.org"];
        description = "KeePassXC integration with native messaging support";
        name = "org.keepassxc.keepassxc_browser";
        path = lib.getExe' service.package "keepassxc-proxy";
        type = "stdio";
      };
    })

    (lib.mkIf service.enable {
      systemd.user.services.keepassxc = {
        Unit = {
          Description = service.package.meta.description;
          After = ["graphical-session.target"];
        };
        Service = {
          Type = "simple";
          KillMode = "process";
          ExecStart = lib.getExe' service.package "keepassxc";
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install = {WantedBy = ["graphical-session.target"];};
      };
    })
  ];
}
