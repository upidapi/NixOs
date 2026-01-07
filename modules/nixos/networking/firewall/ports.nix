{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.networking.firewall.ports;
in {
  options.modules.nixos.networking.firewall.ports = mkEnableOpt "open some ports";

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [
        7071 # for azure func api
        7072
        8081

        # for dev things
        3500
        3501
        3502
        3503

        # for game servers
        6800
        6801
        6802
        6803
        6804
        6805
        6806
        6807
        6808
        6809

        const.ports.mc-server
        const.ports.mc-server-b

        # REF: https://forum.bambulab.com/t/orca-slicer-or-die/135872/270
        # REF: https://www.reddit.com/r/BambuLab/comments/1i4vp5i/lan_mode_with_live_view_remote_monitoringcontrol/
        # bambu
        8883 # MQTT encrypted
        # 1883 # MQTT unencrypted
        322 # camera
        123 # ntp
      ];
      allowedUDPPorts = [
        7071
        7072
        8081

        3500
        3501
        3502
        3503

        # for game servers
        6800
        6801
        6802
        6803
        6804
        6805
        6806
        6807
        6808
        6809

        # bambu
        2021 # discovery
      ];
    };
  };
}
