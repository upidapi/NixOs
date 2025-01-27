{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.env.login.sddm;
in {
  options.modules.nixos.os.env.login.sddm =
    mkEnableOpt "enables the sddm login manager";

  config = mkIf cfg.enable {
    services = {
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
