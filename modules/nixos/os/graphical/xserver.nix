{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.graphical.xserver;
in {
  options.modules.nixos.os.graphical.xserver =
    mkEnableOpt "enables the xserver";

  config = mkIf cfg.enable {
    services = {
      xserver = enable;
    };
  };
}
