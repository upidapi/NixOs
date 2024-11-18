{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.zoxide;
in {
  options.modules.home.cli-apps.zoxide =
    mkEnableOpt "Whether or not to add zoxide a modern replacement for cd";

  config = mkIf cfg.enable {
    programs.zoxide = enable;

    modules.home.terminal.shellAliases = {
      cd = "__zoxide_z";
      cdi = "__zoxide_zi";
    };
  };
}
