{
  config,
  lib,
  self',
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.modules.nixos.misc.prelockd;

  confFile = pkgs.writeText "prelockd.conf" ''
    ${cfg.extraConfig}
  '';
in {
  options.modules.nixos.misc.prelockd = {
    enable = mkEnableOption "enable prelockd, to lock executables and shared libraries in memory to improve system responsiveness under low-memory conditions";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = lib.mdDoc ''
        Extra configuration directives that should be added to
        `prelockd.conf`
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.prelockd = {
      description = "prelockd service user";
      isSystemUser = true;
      home = "/var/lib/prelockd";
      createHome = true;
      group = "prelockd";
    };
    users.groups.prelockd = {};
    systemd = {
      packages = [self'.packages.prelockd];
      services.prelockd = {
        wantedBy = ["multi-user.target"];
        restartTriggers = [confFile];
      };
    };
    environment.etc."prelockd.conf".source = confFile;
  };
}
