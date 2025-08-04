{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.bat;
in {
  options.modules.home.cli-apps.bat =
    mkEnableOpt "enable bat (cat++)";

  config = mkIf cfg.enable {
    # might not what to hardcode this
    programs.bat = enable;
  };
}
