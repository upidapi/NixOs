{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.gh;
in {
  options.modules.home.cli-apps.gh =
    mkEnableOpt "Add github cli";

  config = mkIf cfg.enable {
    programs.gh = enable;
  };
}
