# https://github.com/dutchcoders/transfer.sh
{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (const) ports;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.services.transfer-sh;
in {
  options.modules.nixos.homelab.services.transfer-sh = mkEnableOpt "";

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
          LISTENER = ":${toString ports.transfer-sh}";
        };
      };
      caddy.virtualHosts = {
        "paste.upidapi.dev".extraConfig = ''
          reverse_proxy :${toString ports.transfer-sh}
        '';
      };
    };
  };
}
