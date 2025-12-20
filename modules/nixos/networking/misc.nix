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

    # REF: https://discourse.nixos.org/t/how-to-change-order-of-dns-nameservers/50263/3
    # networking.nameservers = ["1.1.1.1"]; # low priority
    networking.networkmanager.insertNameservers = ["1.1.1.1"]; # highest prio
  };
}
