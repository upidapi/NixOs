{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.unpackerr;
  format = pkgs.formats.toml {};
in {
  options = {
    services.unpackerr = {
      enable = lib.mkEnableOption "unpackerr";

      package = lib.mkPackageOption pkgs "unpackerr" {};

      user = lib.mkOption {
        type = lib.types.str;
        default = "unpackerr";
        description = "User account under which Unpackerr runs.";
      };
      group = lib.mkOption {
        type = lib.types.str;
        default = "unpackerr";
        description = "Group under which Unpackerr runs.";
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/unpackerr";
        description = ''
          The directory where Unpackerr stores its data files.
          This directory will be created if it does not exist.
        '';
      };

      settings = lib.mkOption {
        type = format.type;
        default = {
          debug = false;
        };
        description = lib.mdDoc ''
          Unpackerr configuration. Refer to <https://unpackerr.zip/docs/install/configuration> for details.
        '';
      };

      configFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Path to a custom configuration file for unpackerr. If
          set, this will override the any settings in the `settings` option.
        '';
      };

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        description = ''
          Path to environment files that contain environment variables to pass
          to the unpackerr service, for the purpose of passing secrets to the
          service.
        '';
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.unpackerr = {
      description = "unpackerr";
      wantedBy = ["multi-user.target"];
      serviceConfig = let
        configPath =
          if cfg.configFile != null
          then "${cfg.configPath}"
          else
            format.generate "unpackerr.conf" ({
                log_file = "${cfg.dataDir}/unpackerr.log";
                log_file_mode = "0640";
              }
              // cfg.settings);
      in {
        Type = "simple";

        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;

        EnvironmentFile =
          lib.optional
          (cfg.environmentFile != null)
          cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package} --config ${configPath}";
        Restart = "on-failure";
      };
    };

    users.users = lib.mkIf (cfg.user == "unpackerr") {
      unpackerr = {
        group = cfg.group;
        uid = 389;
        # home = cfg.home;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "unpackerr") {
      unpackerr.gid = 389;
    };
  };
}
