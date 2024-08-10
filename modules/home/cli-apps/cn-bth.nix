{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.cn-bth;
in {
  options.modules.home.cli-apps.cn-bth =
    mkEnableOpt
    "Whether or not to add the cn-bth command";

  # TODO: auto connect to bth?
  #  https://github.com/EzequielRamis/dotfiles/blob/ecfe6f269339d1551768b9158c1d3aee2d82b238/home/timers.nix#L19

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "cn-bth" ''
        bluetoothctl connect AC:80:0A:2E:81:6A
      '')
    ];
  };
}
