{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.boot;
in {
  options.modules.nixos.os.boot =
    mkEnableOpt "whether or not to enable booting";

  config.boot.loader = mkIf cfg.enable {
    systemd-boot = {
      enable = true;
      editor = false;
    };

    efi.canTouchEfiVariables = true;
  };
}
