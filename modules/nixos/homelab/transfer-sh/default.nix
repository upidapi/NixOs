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

  imports = [
    ./base.nix
  ];

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
        stateDirectory = "/var/lib/transfer-sh";
        settings = {
          # FIXME: make this owned by the transger-sh user
          RANDOM_TOKEN_LENGTH = 6;
          # BASEDIR = "/var/lib/transfer-sh";
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
