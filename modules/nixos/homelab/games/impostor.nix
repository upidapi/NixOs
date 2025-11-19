{
  config,
  lib,
  mlib,
  const,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.games.impostor;
in {
  options.modules.nixos.homelab.games.impostor = mkEnableOpt "";

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "games.upidapi.dev".extraConfig = ''
        reverse_proxy :${toString const.ports.game-site}
      '';
      "games-beta.upidapi.dev".extraConfig = ''
        reverse_proxy :${toString const.ports.game-site-beta}
      '';
    };

    systemd.tmpfiles.settings.gameSiteDirs = {
      "/var/lib/game-site"."d" = {
        mode = "700";
        user = "root";
        group = "root";
      };
    };

    systemd.services = {
      # "game-site-db" = {
      #   after = ["network.target"];
      #   whants = ["remote-fs.target"];
      #   path = [];
      #   environment = {
      #     PORT = toString const.ports.game-site;
      #     RELEASE = "prod";
      #   };
      #   serviceConfig = {
      #     User = "upidapi";
      #     Group = "users";
      #
      #     # WorkingDirectory = "/home/upidapi/persist/prog/projects/impostor/";
      #     ExecStart =
      #       pkgs.writeShellScript "run-impostor-prod" ''
      #       '';
      #   };
      # };

      # "game-site" = {
      #   after = ["network.target" "game-site-db.service"];
      #   wantedBy = ["multi-user.target"];
      #   path = [pkgs.nodejs pkgs.bash pkgs.tsx pkgs.git];
      #   environment = {
      #     PORT = toString const.ports.game-site;
      #     RELEASE = "prod";
      #
      #     DATABASE_URL = "file:/home/upidapi/persist/prog/projects/impostor/db.sqlite";
      #   };
      #   serviceConfig = {
      #     # User = "upidapi";
      #     # Group = "users";
      #
      #     WorkingDirectory = "/var/lib/game-site";
      #     ExecStart = pkgs.writeShellScript "run-impostor-prod" ''
      #       if [ -d ".git" ]; then
      #         git pull origin main
      #       else
      #         git clone https://github.com/upidapi/impostor .
      #       fi
      #       npm run build
      #       npm start
      #     '';
      #   };
      # };
      "game-site" = {
        after = ["network.target" "game-site-db.service"];
        wantedBy = ["multi-user.target"];
        path = [pkgs.nodejs pkgs.bash pkgs.tsx];
        environment = {
          PORT = toString const.ports.game-site;
          RELEASE = "beta";

          DATABASE_URL = "file:/home/upidapi/persist/prog/projects/impostor/db.sqlite";
        };
        serviceConfig = {
          User = "upidapi";
          Group = "users";

          WorkingDirectory = "/home/upidapi/persist/prog/projects/impostor/";
          ExecStart = pkgs.writeShellScript "run-impostor-prod" ''
            npm run build
            npm start
          '';
        };
      };
    };
  };
}
