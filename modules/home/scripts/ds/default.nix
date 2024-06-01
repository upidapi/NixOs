{
  config,
  lib,
  pkgs,
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
      (
        pkgs.writers.writePython3Bin
        "ds"
        {
          flakeIgnore = ["E203"];
        }
        (builtins.readFile ./main.py)
      )
    ];
  };
}
