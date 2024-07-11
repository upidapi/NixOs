{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.services.playerctl;
in {
  options.modules.home.services.playerctl =
    mkEnableOpt
    "Whether or not to add the media/player controller, playerctl";

  config = mkIf cfg.enable {
    home.packages = [pkgs.playerctl]; # if user should have the command available as well
    # services.dbus.packages = [pkgs.playerctl]; # if the package has dbus related configuration

    services.playerctld = enable;
  };
}
