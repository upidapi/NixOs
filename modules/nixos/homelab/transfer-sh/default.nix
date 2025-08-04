# https://github.com/dutchcoders/transfer.sh
{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.transfer-sh;
in {
  options.modules.nixos.homelab.transfer-sh = mkEnableOpt "";

  imports = [
    ./base.nix
  ];

  config = mkIf cfg.enable {
    services = {
      transfer-sh = {
        enable = true;
        provider = "local";
        stateDirectory = "/var/lib/transfer-sh";
        settings = {
          RANDOM_TOKEN_LENGTH = 6;
          # BASEDIR = "/var/lib/transfer-sh";
          LISTENER = ":8484";
        };
      };
      caddy.virtualHosts = {
        "paste.upidapi.dev".extraConfig = ''
          reverse_proxy :8484
        '';
      };
    };
  };
}
