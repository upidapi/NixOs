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
    # ./cmp.nix
    # ./dap.ni
    # ./text.nix
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
      defaultEditor = true;

      settings.vim = {
        viAlias = false;
        vimAlias = false;

        hideSearchHighlight = false; # ?
        splitRigt = true;
        lineNumberMode = "relNumber";
        wordWrap = true;

        useSystemClipboard = false; # ?

        tabWidth = 4;

        # n	Normal mode
        # v	Visual mode
        # i	Insert mode
        # c	Command-line mode
        # h	all previous modes when editing a help file
        # a	all previous modes
        # r	for hit-enter and more-prompt prompt
        mouseSupport = "nchr";
        disableArrows = false;

        leaderKey = " ";
        mapTimeout = 500;

        binds = {
          # ? cheatsheet = enable;
          # ? whichKey = enable;
        };

        dashboard = {
          # ? alpha = enable;
        };

        debugMode = {
          enable = false;
          level = 16;
          logFile = "/tmp/nvim.log";
        };
      };
    };
    */
  };
}
