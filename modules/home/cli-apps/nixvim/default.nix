{
  config,
  inputs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt enable;
  cfg = config.modules.home.cli-apps.nixvim;
in {
  imports = [
    # ./../../modules/home
    inputs.nixvim.homeManagerModules.nixvim

    ./cmp.nix
    ./colorscheme.nix
    ./dap.nix

    /*
    ./fmt.nix
    ./keymaps.nix
    ./lsp.nix
    ./todo-comments.nix
    */
  ];

  # TODO: what is oil (probably in the nixos filder?
  # TODO: multiple tabs?
  # TODO: editor regins / folds
  # TODO: autocorrect
  # TODO: add lua snippets

  options.modules.home.cli-apps.nixvim =
    mkEnableOpt "enables nixvim";

  # does this get saved

  # btw ctrl-w + v splits window vertically:
  # btw ctrl-w + s splits window horizintaly
  # btw ctrl-w + q closes window

  # this sets is as the default for the user
  config.home.sessionVariables = {
    EDITOR = "nvim";
  };

  config.programs.nixvim = mkIf cfg.enable {
    enable = true;
    defaultEditor = true;

    enableMan = true; # man pages:

    # extraPlugins = [pkgs.vimPlugins.gruvbox];
    # colorscheme = "gruvbox";
    # dracula

    colorschemes.tokyonight = enable;
    # this is a test

    vimAlias = true;

    options = {
      relativenumber = true; # Show relative line numbers
      number = true; # Show line numbers

      encoding = "utf8";
      expandtab = true;
      modeline = false;
      shiftwidth = 4;
      smartindent = true;
      softtabstop = 4;
      swapfile = false;

      tabstop = 4;
    };

    globals.mapleader = " ";

    plugins = {
      lualine = enable;
      lightline = enable;

      # file browser
      neo-tree = {
        enable = true;
        window.width = 30;
      };

      undotree = enable;

      # code folding
      nvim-ufo = {
        enable = true;
        # closeFoldKinds = {};
        providerSelector = ''
            function(bufnr, filetype, buftype)

              --[=====[
              return a table with string elements:
                1st is name of main provider, 2nd is fallback

              return a string type:
                use ufo inner providers

              return a string in a table:
                like a string type above

              return empty string "":
                disable any providers

              return `nil`:
                use default value {'lsp', 'indent'}

              return a function:
                it will be involved and expected return
                `UfoFoldingRange[]|Promise`

              if you prefer treesitter provider rather than lsp,
              return ftMap[filetype] or {'treesitter', 'indent'}
              --]=====]

              return ""
          end
        '';
      };

      # finding stuff
      telescope = enable;

      # better copying
      # yanky = enable

      # autoclose () [] <> "" etc
      # autoclose = enable;
      nvim-autopairs = enable;
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
        command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2";
      }
      {
        event = ["FileType"];
        pattern = ["py"];
        command = "setlocal shiftwidth=4 tabstop=4 softtabstop=4";
      }
    ];
  };
}
