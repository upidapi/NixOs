{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.tools.playerctl;
in {
  options.modules.nixos.tools.playerctl =
    mkEnableOpt
    "Whether or not to add the media/player controller, playerctl";

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.playerctl]; # if user should have the command available as well
    services.dbus.packages = [pkgs.playerctl]; # if the package has dbus related configuration

    systemd.user.services.playerctld = {
      description = "playerctl daemon";

      wantedBy = ["multi-user.target"];

      # restartIfChanged = true; # set to false, if restarting is problematic

      script = ''
        ${pkgs.playerctl}/bin/playerctld
      '';

      serviceConfig = {
        DynamicUser = true;
      };
    };
  };
}
