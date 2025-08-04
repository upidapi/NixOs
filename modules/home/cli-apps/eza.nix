{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.cli-apps.eza;
in {
  options.modules.home.cli-apps.eza =
    mkEnableOpt "Whether or not to add eza a modern replacement for ls";

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableIonIntegration = false;
      enableNushellIntegration = false;
      enableZshIntegration = false;
    };
  };
}
