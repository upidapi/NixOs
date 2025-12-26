{
  config,
  lib,
  ...
}: let
  mkUserSettins = name: let
    cfg = config.services.${name};
  in {
    options.services.${name} = {
      user = lib.mkOption {
        type = lib.types.str;
        default = "${name}";
        description = "User account under which ${name} runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "${name}";
        description = "Group under which ${name} runs.";
      };
    };

    config = lib.mkIf cfg.enable {
      users.users = lib.mkIf (cfg.user == "${name}") {
        ${name} = {
          group = cfg.group;
          home = cfg.dataDir;
          isSystemUser = true;
        };
      };

      users.groups = lib.mkIf (cfg.group == "${name}") {
        ${name} = {};
      };

      systemd.services.${name}.serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
in {
  imports = [
    (mkUserSettins "prowlarr")
    (mkUserSettins "jellyseerr")
    (mkUserSettins "autobrr")
  ];
}
