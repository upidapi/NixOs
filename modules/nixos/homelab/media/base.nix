{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.services.prowlarr;
in {
  options.services.prowlarr = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "prowlarr";
      description = "User account under which Prowlarr runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "prowlarr";
      description = "Group under which Prowlarr runs.";
    };
  };

  config = mkIf cfg.enable {
    # TODO: upstream this
    users.users = lib.mkIf (cfg.user == "prowlarr") {
      prowlarr = {
        group = cfg.group;
        home = cfg.dataDir;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "prowlarr") {
      prowlarr = {};
    };

    systemd.services.prowlarr.serviceConfig = {
      User = cfg.user;
      Group = cfg.group;
    };
  };
}
