# taken from notashelf
{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualisation.android;
in {
  options.modules.nixos.os.virtualisation.android =
    mkEnableOpt "other android stuff";

  config = mkIf cfg.enable {
    programs.adb = enable;

    # unprivileged use requires "adbusers"
  };
}
