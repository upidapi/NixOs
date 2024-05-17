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
  options.modules.home.scripts.cn-bth =
    mkEnableOpt
    "Whether or not to add the cn-bth command";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "cn-bth" ''
        bluetoothctl connect AC:80:0A:2E:81:6A
      '')
    ];
  };
}
