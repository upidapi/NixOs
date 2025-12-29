{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.autobrr;

  # Define config format and template
  configFormat = pkgs.formats.toml {};
  configTemplate = configFormat.generate "autobrr.toml" cfg.settings;
in {
  disabledModules = ["services/misc/autobrr.nix"];

  options.services.autobrr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Whether or not to enable the Autobrr service.
      '';
    };

    package = mkPackageOption pkgs "autobrr" {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "autobrr";
      description = "User account under which autobrr runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "autobrr";
      description = "Group under which autobrr runs.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Open firewall for the Autobrr port.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/autobrr";
      description = ''
        Specify the data directory for Loki.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {freeformType = configFormat.type;};
      default = {
        host = "0.0.0.0";
        port = 7474;
        checkForUpdates = false;
      };
      example = {
        logLevel = "DEBUG";
      };
      description = ''
        Autobrr configuration options.

        See https://autobrr.com/configuration/autobrr for more information.

        `sessionSecret` is automatically generated upon first installation and will be overridden.
        This is done to ensure that the secret is not hard-coded in the configuration file.
        The actual secret file is generated in the systemd service at `${cfg.dataDir}/session-secret`.
      '';
    };
  };

  config = mkIf cfg.enable {
    # users = {
    #   groups.${cfg.group}.gid = globals.gids.${globals.autobrr.group};
    #   users.${cfg.user} = {
    #     isSystemUser = true;
    #     group = globals.autobrr.group;
    #     uid = globals.uids.${globals.autobrr.user};
    #   };
    # };

    users.users = lib.mkIf (cfg.user == "autobrr") {
      autobrr = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "autobrr") {
      autobrr = {};
    };

    # Create state directory with proper permissions
    systemd.tmpfiles.rules = [
      # no one should read autobrr's state
      "d '${cfg.dataDir}' 0700 ${cfg.user} root - -"
    ];

    # # Configure the autobrr service
    # services.autobrr = {
    #   enable = true;
    #   package = cfg.package;
    #   # We need to provide a secretFile even though we're handling it ourselves
    #   # The actual secret file is generated in the systemd service at
    #   # ${cfg.dataDir}/session-secret
    #   secretFile = "/dev/null"; # This is a placeholder that won't be used
    #   inherit (cfg) settings;
    # };

    networking.firewall = lib.mkIf cfg.openFirewall {allowedTCPPorts = [cfg.settings.port];};

    systemd.services.autobrr = {
      description = "Autobrr";
      after = ["syslog.target" "network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.openssl pkgs.dasel];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        UMask = 066;
        DynamicUser = lib.mkForce false;
        # disable SecretFilec
        LoadCredential = lib.mkForce null;
        # disable state directory
        StateDirectory = lib.mkForce null;
        ExecStartPre = lib.mkForce (pkgs.writeShellScript "autobrr-config-prep" ''
          # Generate session secret if it doesn't exist
          SESSION_SECRET_FILE="${cfg.dataDir}/session-secret"
          if [ ! -f "$SESSION_SECRET_FILE" ]; then
            openssl rand -base64 32 > "$SESSION_SECRET_FILE"
            chmod 600 "$SESSION_SECRET_FILE"
          fi

          # Create config with session secret
          SESSION_SECRET=$(cat "$SESSION_SECRET_FILE")
          cp '${configTemplate}' "${cfg.dataDir}/config.toml"
          chmod 600 "${cfg.dataDir}/config.toml"
          ${pkgs.dasel}/bin/dasel put \
            -f "${cfg.dataDir}/config.toml" \
            -v "$SESSION_SECRET" \
            -o "${cfg.dataDir}/config.toml" "sessionSecret"
        '');
        ExecStart = lib.mkForce "${lib.getExe cfg.package} --config ${cfg.dataDir}";
        Restart = "on-failure";
      };
    };
  };
}
