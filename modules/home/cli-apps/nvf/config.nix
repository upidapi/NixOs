{
  config,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) enable disable;
  cfg = config.modules.home.cli-apps.nvf;
in {
  config = mkIf cfg.enable {
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

      ruff
      pyright
    ];

    programs.nvf = {
      settings.vim = {
        luaPackages = [
          "magick" # for image nvim
        ];

        startPlugins = with pkgs.vimPlugins; [
          (nvim-treesitter.withPlugins (
            parsers:
              with parsers; [
                nix
                markdown
                markdown_inline
                norg
                nu
              ]
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
          "cmp-treesitter"

          "cellular-automaton"
          "toggleterm-nvim"
          "nvim-web-devicons"
          "project-nvim"
          "telescope" # dep: plenary-nvim
          "nvim-dap-ui"

          "image-nvim"

          "diffview-nvim"
          "vim-fugitive"

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

        languages = {
          enableDAP = true;
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          markdown = enable;

          html = enable;
          css = enable;
          tailwind = enable;
          ts = enable; # also adds js support

          nix = {
            enable = true;
            lsp = disable;
            format = disable;
          };
          # // {
          #   lsp.enable = false;
          # };
          go = enable;
          python = {
            enable = true;
            # use ruff
            lsp = disable;
            format = disable;
          };
          bash = enable;
          sql = enable;

          lua = {
            enable = true;
            lsp.neodev = enable;
          };

          rust = {
            enable = true;
            crates = enable;
          };

          clang = {
            enable = true;
            lsp = {
              enable = true;
              server = "clangd";
            };
          };
        };

        # "required" for .language
        treesitter = {
          enable = true;
          autotagHtml = true;

          # show what scopes you're in as horizontal lines
          # context = enable;

          # ? fold = true; (prob use nvim-ufo insted)

          # already set by lang.nix
          # grammars = []

          incrementalSelection = enable;
          indent = enable;

          mappings.incrementalSelection = {
            init = null;
            incrementByNode = null;
            incrementByScope = null;
            decrementByNode = null;
          };
        };

        # i dont think this is needed
        autocomplete.nvim-cmp = {
          enable = true;

          mappings = {
            complete = null;
            close = null;
            confirm = null; # set above

            scrollDocsUp = null;
            scrollDocsDown = null;

            next = null;
            previous = null;
          };
        };

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

        debugger = {
          nvim-dap = {
            enable = true;

            # done in lua
            # ui = enable;

            # what does this do?
            sources = {};

            mappings = {
              # continue = null; -- breaks (errors) rust.nix (in nvf)
              restart = null;
              terminate = null;
              runLast = null;

              toggleRepl = null;
              hover = null;
              toggleBreakpoint = null;

              runToCursor = null;
              stepInto = null;
              stepOut = null;
              stepOver = null;
              stepBack = null;

              goUp = null;
              goDown = null;

              toggleDapUI = null;
            };
          };
        };
      };
    };
  };
}
