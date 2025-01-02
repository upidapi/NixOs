{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.services.ntpd;
in {
  options.modules.nixos.os.services.ntpd = mkEnableOpt "enables time stuff (eg time syncing)";

  config = mkIf cfg.enable {
    time = {
      # Set your time zone.
      timeZone = "Europe/Stockholm";
      hardwareClockInLocalTime = false; # this somehow breaks if Impermanence is enabled
    };

    # FIXME: this does not correctly sync the time

    networking.timeServers = [
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
    ];

    # free, easy-to-use implementation of the Network Time Protocol
    # available as a part of the OpenBSD projeect.
    # since BSDs are known for their superior networking stack, this
    # might provide better performance than the defaults
    environment.systemPackages = [pkgs.openntpd];
    services.openntpd = {
      enable = true;
      extraConfig = ''
        listen on 127.0.0.1
        listen on ::1
      '';
    };
  };
}
