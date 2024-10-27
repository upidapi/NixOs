{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) enable;
  cfg = config.modules.home.cli-apps.nvf;
in {
  imports = [
    ## ./cmp.nix
    ./dap.nix
    ./lang.nix
  ];

  # TODO: various refactoring tools
  #  eg rope for python

  config = mkIf cfg.enable {
    # TODO: fix nix str escape highliting
    #  use :Inspect to inpect under cursor
    #  use :InspectTree to get tresitter output
    #  The problem is that the escape token color thingy is not in the
    #  semantic rokens but in the TreeSitter things
    /*
    Treesitter
    - @string.escape.nix links to @string.escape nix  # <== is here

    Semantic Tokens
    - @lsp.type.string.nix links to String priority: 125  # <== should be here
     - @lsp.type.string.nix links to String priority: 125
    - @lsp.mod.escape.nix links to @lsp priority: 126
    - @lsp.typemod.string.escape.nix links to @lsp priority: 127
    */

    # x = "asd//// \\ \" \\ \${gjkhg} "; y = "";
    home.packages = with pkgs; [
      nixd
      # nixfmt
      nixfmt-rfc-style
      nixpkgs-fmt

      fd # used by treesitter

      # for image nvim
      imagemagick
      curl # (Remote images)
      ueberzugpp
    ];

    programs.nvf = {
      settings.vim = {
        luaPackages = [
          "magick" # for image nvim
        ];

        startPlugins = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (
            parsers: builtins.attrValues {inherit (parsers) nix markdown markdown_inline;}
          ))
          "comment-nvim"
          "nvim-autopairs"
          "todo-comments"
          "tokyonight"
          "neo-tree-nvim"
          "smartcolumn"
          "nvim-colorizer-lua"
          "indent-blankline"
          "highlight-undo"
          "nvim-treesitter"
          "cellular-automaton"
          "toggleterm-nvim"
          "nvim-web-devicons"
          "project-nvim"
          "telescope" # dep: plenary-nvim

          "image-nvim"

          friendly-snippets
          luasnip

          colorizer

          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp_luasnip
          cmp-path
          cmp-cmdline

          none-ls-nvim
          nvim-lspconfig
          lspsaga-nvim

          nord-nvim
          noice-nvim
          lualine-nvim
          bufferline-nvim

          nvim-ufo

          auto-save-nvim

          # why does neorg have so many deps?!
          # start
          "neorg"
          "neorg-telescope"
          "lua-utils-nvim"
          "nui-nvim"
          "nvim-nio"
          "pathlib-nvim"
          "plenary-nvim"
        ];

        # git intergration
        # TODO: binds?
        git.vim-fugitive = enable;

        lsp.mappings = {
          goToDefinition = null;
          goToDeclaration = null;
          goToType = null;
          listImplementations = null;
          listReferences = null;
          nextDiagnostic = null;
          previousDiagnostic = null;
          openDiagnosticFloat = null;
          documentHighlight = null;
          listDocumentSymbols = null;
          addWorkspaceFolder = null;
          removeWorkspaceFolder = null;
          listWorkspaceFolders = null;
          listWorkspaceSymbols = null;
          hover = null;
          signatureHelp = null;
          renameSymbol = null;
          codeAction = null;
          format = null;
          toggleFormatOnSave = null;
        };
        /*
        treesitter = {
          enable = true;
          autotagHtml = true;

          # show shat scopes you're in as horizontal lines
          # context = enable;

          # ? fold = true; (prob use nvim-ufo insted)

          # already set by lang.nix
          # grammars = []

          incrementalSelection = enable;
          indent = enable;

          mappings = {
            # TODO:
          };
        };
        */

        utility = {
          diffview-nvim = enable;

          # prob not
          # motion.leap = enable;

          preview.markdownPreview = enable;

          # surround = enable;
        };
      };
    };
  };
}
