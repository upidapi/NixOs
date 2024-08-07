{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.eza;
in {
  options.modules.home.cli-apps.eza =
    mkEnableOpt "Whether or not to add eza a modern replacement for ls";

  config = mkIf cfg.enable {
    programs.eza = enable;
  };
}
