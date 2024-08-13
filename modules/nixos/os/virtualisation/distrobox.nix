{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualisation.distrobox;
in {
  options.modules.nixos.os.virtualisation.distrobox =
    mkEnableOpt "enables distrobox for running varius distros";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      distrobox
    ];

    # taken from raf
    # but i don't like stuff updating on it's own
    /*
    # if distrobox is enabled, update it periodically
    systemd.user = {
      timers."distrobox-update" = {
        enable = true;
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "1h";
          OnUnitActiveSec = "1d";
          Unit = "distrobox-update.service";
        };
      };

      services."distrobox-update" = {
        enable = true;
        script = ''
          ${pkgs.distrobox}/bin/distrobox upgrade --all
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };
    */
  };
}
