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
    # systemd.tmpfiles.settings."transfer-sh" = {
    #   "/var/lib/transfer.sh" = {
    #     group = ""
    #   };
    # };
    services = {
      transfer-sh = {
        enable = true;
        provider = "local";
        settings = {
          # FIXME: make this owned by the transger-sh user
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
