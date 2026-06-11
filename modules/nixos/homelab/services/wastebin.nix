{
  config,
  lib,
  mlib,
  self,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.services.wastebin;
in {
  options.modules.nixos.homelab.services.wastebin = mkEnableOpt "";

  config = mkIf cfg.enable {
    sops.secrets = {
      "wastebin/sign-key" = {
        sopsFile = "${self}/secrets/server.yaml";
        restartUnits = ["wastebin.service"];
      };
      "wastebin/psw-salt" = {
        sopsFile = "${self}/secrets/server.yaml";
        restartUnits = ["wastebin.service"];
      };
    };
    sops.templates."wastebin-env".content = ''
      WASTEBIN_SIGNING_KEY=${config.sops.placeholder."wastebin/sign-key"}
      WASTEBIN_PASSWORD_SALT=${config.sops.placeholder."wastebin/psw-salt"}
    '';
    services = {
      caddy.virtualHosts = {
        "paste.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.wastebin}
        '';
      };
      wastebin = {
        enable = true;
        secretFile = config.sops.templates."wastebin-env".path;
        settings = {
          WASTEBIN_TITLE = "wastebin";
          WASTEBIN_BASE_URL = "https://paste.upidapi.dev";
          WASTEBIN_ADDRESS_PORT = "[::]:${toString ports.wastebin}";

          # note that cloudflare limits posts to 100 MB
          # https://gridpane.com/kb/cloudflares-cdn-and-upload-limitations/
          WASTEBIN_MAX_BODY_SIZE = 1024 * 1024 * 1024 * 10; # 10Gb
          # default to 1 month expiration
          # still allow never
          WASTEBIN_PASTE_EXPIRATIONS = "0,10m,1h,1d,1w,1M=d,1y";
        };
      };
    };
  };
}
