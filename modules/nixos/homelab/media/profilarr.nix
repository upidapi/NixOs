{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.media.profilarr;

  dataDir = "/var/lib/profilarr";
in {
  options.modules.nixos.homelab.media.profilarr = mkEnableOpt "";

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.profilarr = {
      image = "santiagosayshey/profilarr:latest";
      ports = ["6868:${toString ports.profilarr}"];
      environment = {
        TZ = "Europe/Helsinki";
      };
      volumes = [
        "${dataDir}:/config"
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${dataDir} 0755 1000 1000 - -"
    ];
  };
}
