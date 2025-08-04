{
  pkgs,
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.programs.less;
in {
  options.modules.nixos.os.programs.less =
    mkEnableOpt
    "enables the less pager";

  /*
     config.home = mkIf cfg.enable {
    packages = [
      pkgs.less
    ];

    sessionVariables = {
      PAGER = "less";
      MANPAGER = "less";
      EDITOR = "nvim";
    };
  };
  */

  config.environment = mkIf cfg.enable {
    systemPackages = [
      pkgs.less
    ];

    sessionVariables = {
      PAGER = "less";
      MANPAGER = "less";
    };
  };
}
