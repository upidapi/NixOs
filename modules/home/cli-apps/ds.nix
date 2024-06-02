{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.scripts.ds;
in {
  options.modules.home.scripts.ds =
    mkEnableOpt
    "Whether or not to add the ds (dev-shell) command";
  config = mkIf cfg.enable {
    home.packages = [
      # todo: add the custom ds pkg here
    ];
  };
}
