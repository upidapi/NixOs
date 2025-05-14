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

  # REF: https://github.com/hugo-berendi/yomi/blob/29a848529e6b2dcb81f6830a1161cc29c38e3c6d/hosts/nixos/inari/services/ddclient.nix
  config = mkIf cfg.enable {
    sops.secrets."ddclient-cf-token" = {
      # owner = "ddclient";
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
      upidapi.com

      protocol=cloudflare
      password=${config.sops.placeholder.ddclient-cf-token}
      zone=upidapi.dev
      upidapi.dev, ssh.upidapi.dev
    '';

    services.ddclient = {
      enable = true;
      configFile = config.sops.templates."ddclient.conf".path;
    };
  };
}
