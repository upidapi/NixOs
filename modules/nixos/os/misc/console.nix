{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.os.misc.console;
in {
  options.modules.nixos.os.misc.console = mkEnableOpt "enables various console things";

  # TODO: change font size
  # TODO: possibly kmscon (term emulator ish) https://github.com/NotAShelf/nyx/blob/1549b05d8c8a4380a44c5e53d8214ab3c62dddf3/modules/core/common/system/os/misc/console.nix#L25
  config = mkIf cfg.enable {
    # Configure console keymap
    console.keyMap = "sv-latin1";
    # console.useXkbConfig = true;
  };
}
