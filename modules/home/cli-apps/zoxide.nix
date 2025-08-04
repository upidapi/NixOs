{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.zoxide;
in {
  options.modules.home.cli-apps.zoxide =
    mkEnableOpt "Whether or not to add zoxide a modern replacement for cd";

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      options = [
        "--no-cmd"
      ];
    };

    modules.home.terminal.shellAliases = {
      cd = "__zoxide_z";
      cdi = "__zoxide_zi";
    };
  };
}
