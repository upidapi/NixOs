{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.games.ark-ase;
in {
  options.modules.nixos.homelab.games.ark-ase = mkEnableOpt "";

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/ark-ase/ 0755 1000 1000 -"
      "d /var/lib/ark-ase/backup 0755 1000 1000 -"
    ];

    virtualisation.oci-containers.containers = {
      ark-island = {
        image = "hermsi/ark-server:latest";
        volumes = [
          "/var/lib/ark-ase:/app"
          "/var/lib/ark-ase/backup:/home/steam/ARK-Backups"
        ];
        extraOptions = ["--network=host"];
        environment = {
          SESSION_NAME = "penis-o-atfc";
          SERVER_MAP = "TheIsland";
          SERVER_PASSWORD = "ensdfasdi";
          ADMIN_PASSWORD = "ensdfasdi";
          MAX_PLAYERS = "20";
          UPDATE_ON_START = "false";
          BACKUP_ON_STOP = "false";
          PRE_UPDATE_BACKUP = "true";
          WARN_ON_STOP = "true";
          ENABLE_CROSSPLAY = "false";
          DISABLE_BATTLEYE = "true";
          ARK_SERVER_VOLUME = "/app";
          GAME_CLIENT_PORT = "6807";
          SERVER_LIST_PORT = "6808";
          # UDP_SOCKET_PORT = "6808";
          RCON_PORT = "6809";
          GAME_MOD_IDS = "558651608,1999447172";

          # GAME_MOD_IDS = "679529026,902616446,1373744537,1445395055,848706943,558651608,1565015734,1300713111,1999447172,821530042";
        };
      };
    };
  };
}
