{
  config,
  lib,
  mlib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.orca-slicer;
in {
  options.modules.home.apps.orca-slicer = mkEnableOpt "";

  imports = [
    inputs.open-bamboo-networking.homeManagerModules.default
  ];

  config = mkIf cfg.enable {
    programs.open-bamboo-networking = {
      enable = true;
      target = "orca-slicer";
    };

    home.packages = [
      (pkgs.orca-slicer.override {
        withNvidiaGLWorkaround = true; # I have nvidia
        glew = pkgs.glew.override {
          enableEGL = false;
        };
      })
    ];
  };
}
