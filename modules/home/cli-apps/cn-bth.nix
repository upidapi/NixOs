{
  config,
  lib,
  pkgs,
  mlib,
  ...
}: let
  inherit (lib) mkIf types mkOption;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.cli-apps.cn-bth;
in {
  options.modules.home.cli-apps.cn-bth =
    (mkEnableOpt "Whether or not to add the cn-bth command")
    // {
      deviceAddr = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The device cn-bth tries to connect to";
      };
    };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.enable || cfg.deviceAddr != null;
        message = ".deviceAddr required for cn-bth to work";
      }
    ];
    home.packages = [
      (pkgs.writeShellScriptBin "cn-bth" ''
        bluetoothctl connect ${cfg.deviceAddr}
      '')
    ];
  };
}
