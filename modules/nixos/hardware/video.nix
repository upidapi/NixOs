{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.hardware.video;
in {
  options.modules.nixos.hardware.video = mkEnableOpt "enables video stuff";

  config = mkIf cfg.enable {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = with pkgs.stdenv;
          hostPlatform.isLinux && hostPlatform.isx86;
      };
    };

    # benchmarking tools
    environment.systemPackages = with pkgs; [
      mesa-demos
      glmark2
    ];
  };
}
