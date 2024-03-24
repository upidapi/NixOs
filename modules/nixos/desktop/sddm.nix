{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.desktop.sddm;
in {
  options.modules.nixos.desktop.sddm =
    mkEnableOpt "enables the sddm login manager";

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
