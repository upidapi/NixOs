{
  config,
  mlib,
  lib,
  pkgs,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualisation.distrobox;
in {
  options.modules.nixos.os.virtualisation.distrobox =
    mkEnableOpt "enables distrobox for running varius distros";

  /*
  distrobox list --root
  distrobox create --root
  distrobox enter my-distrobox --root

  distrobox create -Y --name Arch --image docker.io/library/archlinux:latest --absolutely-disable-root-password-i-am-really-positively-sure --root
  distrobox enter --root Arch
  */
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
