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
          # TODO: disable E203 globally since it conflicts with ruff
          flakeIgnore = ["W291" "W293" "E501" "E303" "W503" "E203"];
        }
        (builtins.readFile ./main.py)
      )
    ];
  };
}
