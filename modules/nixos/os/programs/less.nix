{
  pkgs,
  config,
  mlib,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.programs.less;
in {
  options.modules.nixos.os.programs.less =
    mkEnableOpt
    "enables the less pager";

  config.environment = mkIf cfg.enable {
    systemPackages = [
      pkgs.less
    ];
  };
}
