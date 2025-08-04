{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.networking.misc;
in {
  options.modules.nixos.os.networking.misc = mkEnableOpt "";

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
  };
}
