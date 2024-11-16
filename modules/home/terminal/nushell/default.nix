{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.terminal.nushell;
in {
  options.modules.home.terminal.nushell =
    mkEnableOpt "Whether or not to enable nushell";

  config.programs = mkIf cfg.enable {
    nushell = {
      enable = true;

      extraConfig = builtins.readFile ./config.nu;

      # the default is broken, set in config.nu insted
      shellAliases =
        builtins.removeAttrs
        config.modules.home.terminal.shellAliases
        ["e"];
    };

    # multi-shell multi-command argument completer
    carapace.enable = true;
  };
}
