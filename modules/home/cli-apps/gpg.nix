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
    # TODO: take a look at https://github.com/NotAShelf/nyx/blob/main/homes/notashelf/programs/terminal/tools/gpg.nix
    # TODO: add EXPLORE: for things to take a look at
    services.gpg-agent = {
      enable = true;
      # enableScDaemon = true; # ?
      enableSshSupport = true;
      # enableExtraSocket = true;
      # enableZshIntegration = true;
    };

    programs.gpg = {
      enable = true;
      # homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
