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
      use = "web, web=https://api.ipify.org/";
      verbose = true;
      ssl = true;
      username = "token";
      protocol = "cloudflare";
      zone = "dns.zone";
      domains = [
        "upidapi.com"
        "upidapi.dev"
        "ssh.upidapi.dev"
      ];
      passwordFile = "${config.sops.secrets."ddclient-cf-token".path}";
    };
  };
}
