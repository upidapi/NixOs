{
  config,
  lib,
  pkgs,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
  cfg = config.modules.home.services.playerctl;
in {
  options.modules.home.services.playerctl =
    mkEnableOpt
    "Whether or not to add the media/player controller, playerctl";

  config = mkIf cfg.enable {
    # if user should have the command available as well
    home.packages = [pkgs.playerctl];

    # services.dbus.packages = [pkgs.playerctl];
    # if the package has dbus related configuration

    services.playerctld = enable;
  };
}
