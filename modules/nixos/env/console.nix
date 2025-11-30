{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.env.console;
in {
  options.modules.nixos.env.console = mkEnableOpt "enables various console things";

  config = mkIf cfg.enable {
    # Configure console keymap
    # configen in keyboard.nix
    # console.keyMap = "sv-latin1";
    # console.useXkbConfig = true;
  };
}
