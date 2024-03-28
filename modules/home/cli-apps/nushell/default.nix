{
  config,
  # pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.nushell;
in {
  options.modules.home.cli-apps.nushell =
    mkEnableOpt "Whether or not to enable nushell";

  config.programs = mkIf cfg.enable {
    # shell = pkgs.nushell;
    nushell = {
      configFile.source = ./config.nu;

      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        c = "clear";
      };
    };

    carapace.enable = true;
    carapace.enableNushellIntegration = true;

    /* starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    }; */
  };
}
