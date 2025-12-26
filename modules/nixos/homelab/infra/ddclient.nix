{
  config,
  lib,
  mlib,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.ddclient;
in {
  options.modules.nixos.homelab.ddclient = mkEnableOpt "ddclient";

  # REF: https://github.com/hugo-berendi/yomi/blob/29a848529e6b2dcb81f6830a1161cc29c38e3c6d/hosts/nixos/inari/services/ddclient.nix
  config = mkIf cfg.enable {
    # (2025-07-16) just like the arr apps, when it requests
    #   /var/lib/private it might have the 755 perms which it rejects
    #   i have a tmpfiles rule that should've fixed that but it doesn't
    #   seam to resolve it. At leas not when restarting the service
    # (2025-07-30) seams to no longer be an issue
    sops.secrets."ddclient-cf-token" = {
      sopsFile = "${self}/secrets/server.yaml";
    };

    # it seams like it doesn't work if you don't explicitly provide the zone
    sops.templates."ddclient.conf".content = ''
      # General settings
      cache=/var/lib/ddclient/ddclient.cache
      foreground=YES
      use=web, web=https://api.ipify.org/
      ssl=yes
      verbose=yes
      quiet=no

      protocol=cloudflare
      password=${config.sops.placeholder.ddclient-cf-token}
      zone=upidapi.com
      upidapi.com, *.upidapi.com

      protocol=cloudflare
      password=${config.sops.placeholder.ddclient-cf-token}
      zone=upidapi.dev
      wildcard=yes
      upidapi.dev, ssh.upidapi.dev, vpn.upidapi.dev, mc.upidapi.dev, *.upidapi.dev
    '';

    users.groups.ddclient = {};
    users.users.ddclient = {
      isSystemUser = true;
      group = "ddclient";
    };

    services.ddclient = {
      enable = true;
      configFile = config.sops.templates."ddclient.conf".path;
      interval = "5min";
    };
  };
}
