{
  config,
  lib,
  mlib,
  const,
  inputs,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.services.upi-paste;
in {
  imports = [inputs.upi-paste.nixosModules.default];
  options.modules.nixos.homelab.services.upi-paste = mkEnableOpt "";

  config = mkIf cfg.enable {
    sops.secrets."upi-paste-token" = {
      sopsFile = "${self}/secrets/server.yaml";
    };
    sops.templates."upi-paste-env" = {
      content = ''
        TOKEN_SECRET=${config.sops.placeholder."upi-paste-token"}
      '';
    };

    services = {
      caddy.virtualHosts = {
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

      upi-paste = {
        enable = true;
        port = ports.upi-paste;
        maxUploadBytes = 10 * 1024 * 1024 * 1024; # 10Gb
        environmentFile = config.sops.templates."upi-paste-env".path;
      };
    };
  };
}
