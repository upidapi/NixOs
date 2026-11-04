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
  cfg = config.modules.nixos.homelab.infra.harmonia;
in {
  options.modules.nixos.homelab.infra.harmonia = mkEnableOpt "";

  config = mkIf cfg.enable {
    sops.secrets = {
      "harmonia/key-pub" = {
        sopsFile = "${self}/secrets/server.yaml";
      };
      "harmonia/key-priv" = {
        sopsFile = "${self}/secrets/server.yaml";
      };
    };

    services = {
      harmonia.cache = {
        enable = true;
        # nix-store --generate-binary-cache-key cache.yourdomain.tld-1 harmonia.secret harmonia.pub
        signKeyPaths = [config.sops.secrets."harmonia/key-priv".path];
        settings = {
          bind = "127.0.0.1:${toString ports.harmonia}";
        };
      };

      caddy.virtualHosts = {
        # "upidapi.dev".extraConfig = ''
        # '';
        "cache.upidapi.dev".extraConfig = ''
          import harden_headers

          reverse_proxy :${toString ports.harmonia}
        '';
      };
    };
  };
}
