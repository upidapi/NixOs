{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.scripts.cn-bth;
in {
  # todo: actually make this true
  # Tries to connect to all of your listed devices in
  # modules/nixos/hardware/bth.
  # You can do this with python.

  options.modules.home.scripts.cn-bth =
    mkEnableOpt
    "Whether or not to add the cn-bth command";

  config = mkIf cfg.enable {
    home.packages = [
      /*
      (pkgs.writeShellScriptBin "cn-bth" ''
        echo -e "connect AC:80:0A:2E:81:6A\nquit" | bluetoothctl
      '')
      */

      (
        pkgs.writers.writePython3Bin
        "cn-bth"
        {
          flakeIgnore = ["W291" "W293" "E501" "E303" "W503"];
        }
        (builtins.readFile ./main.py)
      )
    ];
  };
}
