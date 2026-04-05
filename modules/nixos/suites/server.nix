{
  mlib,
  config,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf mkDefault;
  cfg = config.modules.nixos.suites.server;
  enable = {
    enable = mkDefault true;
  };
  enableAnd = x: enable // x;
  # disable = {
  #   enable = mkDefault false;
  # };
in {
  options.modules.nixos.suites.server =
    mkEnableOpt "";

  config = mkIf cfg.enable {
    modules.nixos = {
      homelab = {
        media = enableAnd {
          jellyfin = enable;
          jellyseerr = enable;
          arr = enable;
          # autobrr = enable;
          unpackerr = enable;
          qbit = enable;
          cross-seed = enable;
          # profilarr = enable;
        };

        infra = {
          tofu = enable;

          ddclient = enable;
          caddy = enable;
          authelia = enable;
        };

        services = {
          transfer-sh = enable;
          # wg-easy = enable;
          # homepage = enable;
          thelounge = enable;
        };

        games = {
          impostor = enable;
          necesse = enable;
          minecraft = enable;
        };
      };

      networking = {
        # wireguard.server = enable;
        # vpn.mullvad = {
        #   enable = true;
        #   createNamespace = true;
        # };

        vpn.namespaces = enableAnd {
          proton = true;
        };
      };
    };
  };
}
