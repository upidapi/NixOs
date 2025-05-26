# https://github.com/dutchcoders/transfer.sh
{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.homelab.transfer-sh;
in {
  options.modules.nixos.homelab.transfer-sh = mkEnableOpt "";

  config = mkIf cfg.enable {
    services = {
      transfer-sh = {
        provider = "local";
        settings = {
          BASEDIR = "/var/lib/transfer.sh";
          LISTENER = ":8484";
        };
      };
      caddy.virtualHosts = {
        "paste.upidapi.dev".extraConfig = ''
          reverse_proxy 127.0.0.1:8484
        '';
      };
    };
  };
}
