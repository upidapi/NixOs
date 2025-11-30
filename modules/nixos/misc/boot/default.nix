{
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.misc.boot;
in {
  options.modules.nixos.misc.boot =
    mkEnableOpt "whether or not to enable booting";

  config.boot.loader = mkIf cfg.enable {
    systemd-boot = {
      enable = true;
      editor = false;
    };

    efi.canTouchEfiVariables = true;
  };
}
