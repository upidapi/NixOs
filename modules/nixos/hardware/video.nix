{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf isx86Linux;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.hardware.video;
in {
  options.modules.nixos.hardware.video = mkEnableOpt "enables video stuff";

  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = isx86Linux pkgs;
      };
    };

    # benchmarking tools
    environment.systemPackages = with pkgs; [
      glxinfo
      glmark2
    ];
  };
}
