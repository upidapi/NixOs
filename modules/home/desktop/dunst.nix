{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.desktop.dunst;
in {
  options.modules.home.desktop.dunst =
    mkEnableOpt "enables dunst, a notification handler";

  config = mkIf cfg.enable {
    services.dunst.enable = true;

    home.packages = with pkgs; [
      dunst # notifications
      libnotify # notofication dep
    ];
  };
}
