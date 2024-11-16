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
      extraConfig = builtins.readfile ./config.nu;

      inherit (config.modules.home.terminal) shellAliases;
    };

    # multi-shell multi-command argument completer
    carapace.enable = true;
  };
}
