# taken from notashelf
{
  pkgs,
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt enable;
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
