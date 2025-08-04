{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib.opt) mkEnableOpt;
  cfg = config.modules.home.terminal.nushell;
in {
  options.modules.home.terminal.nushell =
    mkEnableOpt "Whether or not to enable nushell";

  config = mkIf cfg.enable {
    programs = {
      nushell = {
        enable = true;

        extraConfig = builtins.readFile ./config.nu;

        # the default is broken, set in config.nu instead
        shellAliases =
          builtins.removeAttrs
          config.modules.home.terminal.shellAliases
          ["e"];
      };

      # multi-shell multi-command argument completer
      carapace.enable = true;
    };

    # used for git completions
    home.packages = with pkgs; [
      fish
      carapace-bridge
    ];
  };
}
