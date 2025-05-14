{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.ddclient;
in {
  options.modules.nixos.homelab.ddclient = mkEnableOpt "ddclient";

  config = mkIf cfg.enable {
    sops.secrets."ddclient-cf-token" = {};

    services.ddclient = {
      enable = true;
      verbose = true;
      ssl = true;
      username = "token";
      protocol = "cloudflare";
      domains = [
        "upidapi.com"
        "upidapi.dev"
      ];
      passwordFile = config.sops.secrets."ddclient-cf-token".path;
    };
  };
}
