{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.git;
in {
  options.modules.home.cli-apps.git =
    mkEnableOpt "enable bat (cat++)";

  config = mkIf cfg.enable {
    # might not what to hardcode this
    programs.bat = enable;
  };
}
