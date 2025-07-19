{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.gpg;
in {
  options.modules.home.cli-apps.gpg = mkEnableOpt "enables pgp";
  config = mkIf cfg.enable {
    services.gpg-agent = {
      enable = true;
      # enableScDaemon = true; # ?
      # enableSshSupport = true; ?
      # enableExtraSocket = true;
      # enableZshIntegration = true;
    };

    programs.gpg = {
      enable = true;
      # homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
