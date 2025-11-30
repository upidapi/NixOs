{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.networking.misc;
in {
  options.modules.nixos.networking.misc = mkEnableOpt "";

  config = mkIf cfg.enable {
    # REF: https://askubuntu.com/questions/45072/how-to-control-internet-access-for-each-program
    # create a group that cant access the internet
    # usage: sudo -g no-internet ...
    networking.firewall = {
      extraCommands = ''
        iptables -I OUTPUT 1 -m owner --gid-owner no-internet -j DROP
        ip6tables -I OUTPUT 1 -m owner --gid-owner no-internet -j DROP
      '';
    };
    users.groups.no-internet = {};

    networking.nameservers = ["1.1.1.1"];
  };
}
