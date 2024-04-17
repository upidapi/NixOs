{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.scripts.qs;
in {
  options.modules.home.scripts.qs =
    mkEnableOpt
    "Whether or not to add the qs command";

  config = mkIf cfg.enable {
    home.packages = [
      (
        pkgs.writers.writePython3Bin
        "qs"
        {
          flakeIgnore = ["W291" "W293" "E501" "E303" "W503"];
        }
        (builtins.readFile ./core.py)
      )
    ];
  };
}
