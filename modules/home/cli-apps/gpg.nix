{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.cli-apps.gpg;
in {
  options.modules.home.cli-apps.gpg = mkEnableOpt "enables pgp";
  config = mkIf cfg.enable {
    services.gpg-agent = {
      # enable = true; # BROKEN: idk why
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
