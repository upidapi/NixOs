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
    services.caddy.virtualHosts."games.upidapi.dev".extraConfig = ''
      reverse_proxy :${toString const.ports.impostor}
    '';

    systemd.services."imposor-game" = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.nodejs pkgs.bash];
      environment.PORT = toString const.ports.impostor;
      serviceConfig = {
        User = "upidapi";
        Group = "users";

        # FIXME: huge botch

        WorkingDirectory = "/home/upidapi/persist/prog/projects/impostor/";
        ExecStartPre = "${pkgs.nodejs}/bin/npm run build";
        ExecStart = "${pkgs.nodejs}/bin/npm start";
      };
    };
  };
}
