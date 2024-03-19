{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.less;
in {
  options.modules.nixos.less = mkEnableOpt "enables the less pager";
}
