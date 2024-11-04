{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.env.graphical.xserver;
in {
  options.modules.nixos.os.env.graphical.xserver =
    mkEnableOpt "enables the xserver";

  config = mkIf cfg.enable {
    services = {
      xserver = enable;
    };
  };
}
