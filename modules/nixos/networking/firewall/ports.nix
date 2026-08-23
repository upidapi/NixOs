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

  # TODO: split this into modules?
  # NOTE: don't forget that there's separate settings for opening TCP and UDP
  config = mkIf cfg.enable {
    networking.firewall = {
      # for game servers
      allowedTCPPortRanges = [
        {
          from = 25500;
          to = 25599;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 25500;
          to = 25599;
        }
      ];

      allowedTCPPorts = [
        7071 # for azure func api
        7072
        8081

        # for dev things
        3500
        3501
        3502
        3503

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

        # bambu
        2021 # discovery
      ];
    };
  };
}
