{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.apps.less;
in {
  options.modules.nixos.apps.less = mkEnableOpt "enables the less pager";

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
