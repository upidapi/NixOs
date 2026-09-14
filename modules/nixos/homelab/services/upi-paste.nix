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
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.services.upi-paste;
in {
  options.modules.nixos.homelab.services.upi-paste = mkEnableOpt "";

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "p.upidapi.dev".extraConfig = ''
        handle /api/upload* {
            reverse_proxy :${toString const.ports.upi-paste} {
                flush_interval -1
            }
        }

        handle {
            reverse_proxy :${toString const.ports.upi-paste}
        }
      '';
    };

    systemd.services = {
      "upi-paste" = {
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
        path = [pkgs.nodejs pkgs.bash];
        environment = {
          PORT = toString const.ports.upi-paste;
          RELEASE = "beta";
        };
        serviceConfig = {
          User = "upidapi";
          Group = "users";

          WorkingDirectory = "/home/upidapi/persist/prog/projects/upi-paste";
          ExecStart = pkgs.writeShellScript "run-upi-paste" ''
            npm run build
            npm start
          '';
        };
      };
    };
  };
}
