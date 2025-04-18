{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.cn-phone;
in {
  options.modules.home.cli-apps.cn-phone =
    mkEnableOpt "Whether or not to add the cn-phone command";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "cn-phone" ''
        PAGER=cat nmcli device wifi list --rescan yes
        nmcli device wifi connect upi-phone
      '')
    ];
  };
}
