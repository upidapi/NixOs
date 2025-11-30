{
  config,
  lib,
  pkgs,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.misc.services.restic;
in {
  options.modules.nixos.misc.services.restic =
    mkEnableOpt "Add restic for backups";

  config = mkIf cfg.enable {
    sops.secrets."restic/password" = {};
    # sops.secrets.ame-s3 = {sopsFile = ../../../secrets/s3/secrets.yaml;};
    environment.systemPackages = [pkgs.restic];
    services.restic = {
      # TODO: remote backups eg:
      #  https://github.com/notohh/snowflake/blob/master/hosts/ame/services/restic.nix
      backups = {
        local = {
          paths = [
            "/home/*/persist"
          ];
          exclude = [
            "/home/*/persist/tmp"
          ];
          pruneOpts = [
            "--keep-daily=7"
            "--keep-weekly=8"
            "--keep-monthly=12"
            "--keep-yearly=100"
          ];
          initialize = true;
          # repository = "s3:https://s3.flake.sh/restic-ame";
          repository = "/srv/restic-repo";
          passwordFile = config.sops.secrets."restic/password".path;
          # environmentFile = config.sops.secrets.ame-s3.path;
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
          };
        };
      };
    };
  };
}
