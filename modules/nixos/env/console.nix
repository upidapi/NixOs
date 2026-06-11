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
    # enables (stable) terminfo for a bunch of extra terminals that aren't in ncurses yet (ghostty, alacritty, kitty, etc)
    # makes eg "less" work in pesu
    environment.enableAllTerminfo = true;
    # Configure console keymap
    # configen in keyboard.nix
    # console.keyMap = "sv-latin1";
    # console.useXkbConfig = true;
  };
}
