{
  config,
  inputs,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.nixvim;
in {
  imports = [
    inputs.nvf.homeManagerModules.nvf
  ];

  options.modules.home.cli-apps.nvf =
    mkEnableOpt "enables nvf a neovim distro powerd by nix";

  config = mkIf cfg.enable {
    /*
    home.sessionVariables = {
      EDITOR = "nvim";
    };
    */

    home.packages = [inputs.nvf.packages.${pkgs.stdenv.system}.docs-manpages];

    /*
    programs.nvf = {
      enable = false;
      enableManpages = true;
      defaultEdittor = true;

      settings.vim = {
        viAlias = false;
        vimAlias = false;

        spellcheck = {
          enable = true;
        };
      };
    };
    */
  };
}
