{
  config,
  inputs,
  pkgs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.apps.nixvim;
in {
  imports = [
    # ./../../modules/home
    inputs.nixvim.homeManagerModules.nixvim
  ];

  options.modules.home.apps.nixvim =
    mkEnableOpt "enables nixvim";

  config.programs.nixvim = mkIf cfg.enable {
    enable = true;
    defaultEditor = true;

    # extraPlugins = [pkgs.vimPlugins.gruvbox];
    # colorscheme = "gruvbox";

    colorschemes.gruvbox = enable;

    vimAlias = true;

    options = {
      # number = true;
      relativeNumber = true;
      enableMan = true; # man pages

      encoding = "utf8";
      expandtab = true;
      modeline = false;
      shiftwidth = 4;
      smartindent = true;
      softtabstop = 4;
      swapfile = false;
      tabstop = 4;
    };

    plugins = {
      lightline = enable;
      # nil = enable;
      lsp.servers.nil_ls = {
        enable = true;
      };
    };
    autoCmd = [
      /*
         {
        event = ["TermOpen"];
        pattern = ["*"];
        command = "startinsert";
      }
      */

      # changes some config when in nix files
      {
        event = ["FileType"];
        pattern = ["nix"];
        command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab";
      }
    ];
  };
}
