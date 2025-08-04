{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.os.misc.console;
in {
  options.modules.nixos.os.misc.console = mkEnableOpt "enables various console things";

  config = mkIf cfg.enable {
    # Configure console keymap
    # configen in keyboard.nix
    # console.keyMap = "sv-latin1";
    # console.useXkbConfig = true;
  };
}
