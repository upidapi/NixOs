{
  config,
  inputs,
  lib,
  my_lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) enable disable;
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
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
    ];

    programs.nvf = {
      settings.vim = {
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

          # nord-nvim
          noice-nvim
          lualine-nvim
          bufferline-nvim

          nvim-ufo

          auto-save-nvim
        ];

        binds = {
          # ? cheatsheet = enable;
          # ? whichKey = enable;
        };

        dashboard = {
          # ? alpha = enable;
        };

        # TODO: neorg
        # https://github.com/Soliprem/nix-config/blob/main/home-manager/nvim.nix

        # git intergration
        # TODO: binds?
        git.vim-fugitive = enable;

        notify = {
          # ? nvim-notify = enable;
        };

        projects.project-nvim = enable;

        maps = let
          m = {
            "<up>".action = "g<up>";
            "<down>".action = "g<down>";
          };
        in {
          normal =
            {
              "<leader>fz".action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";

              # neo tree
              "<leader>tt".action = "<cmd>Neotree toggle<CR>";
              "<leader>tu".action = "<cmd>Neotree<CR>";
              "<leader>tr".action = "<cmd>Neotree reveal<CR>";
              "Ö".action = ":";
            }
            // m;
          insert = {
            "<up>".action = "<c-o>g<up>";
            "<down>".action = "<c-o>g<down>";
          };
          visual = m;
          terminal."<Esc>".action = "<C-\><C-n>";
        };

        telescope = {
          enable = true;
          mappings = {
            findProjects = "<leader>fp"; # "<leader>fp";
            findFiles = "<leader>ff"; # "<leader>ff";
            buffers = "<leader>fb"; # "<leader>fb";

            liveGrep = "<leader>fg"; # "<leader>fg";
            helpTags = null; # "<leader>fh";
            open = null; # "<leader>ft";

            diagnostics = null; # "<leader>fld";
            treesitter = null; # "<leader>fs";

            gitCommits = "<leader>fC"; # "<leader>fvcw";
            gitBufferCommits = "<leader>fc"; # "<leader>fvcb";
            gitBranches = null; # "<leader>fvb";
            gitStatus = null; # "<leader>fvs";
            gitStash = null; # "<leader>fvx";

            lspDocumentSymbols = null; # "<leader>flsb";
            lspWorkspaceSymbols = null; # "<leader>flsw";
            lspReferences = null; # "<leader>flr";
            lspImplementations = null; # "<leader>fli";
            lspDefinitions = null; # "<leader>flD";
            lspTypeDefinitions = null; # "<leader>flt";
          };
        };

        terminal = {
          toggleterm = {
            enable = true;
            mappings = {
              open = "<c-t>";
            };
          };
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
          # NOTE: ccc breaks nixd :)
          /*
          ccc = {
            enable = true;
            mappings = {
              decrease10 = "<H>";
              increase10 = "<L>";
              quit = "<Esc>";
            };
          };
          */

          diffview-nvim = enable;
          # icon-picker = enable;

          images.image-nvim = {
            # doesn't work
            # enable = true;
            # setupOpts.backend = "ueberzug"; # TODO: "kitty"; ?
          };

          # prob not
          # motion.leap = enable;

          preview.markdownPreview = enable;

          # surround = enable;
        };

        visuals = {
          # TODO: nvim ufo

          enable = true;

          # give characters gravity
          cellularAutomaton = {
            enable = true;

            # add game_of_life?
            mappings.makeItRain = "<leader>fml";
          };

          # for notifications
          # fidget-nvim = enable; ?

          highlight-undo = enable;

          indentBlankline = {
            enable = true;
            # debounce = 0; ?
          };

          nvimWebDevicons = enable;

          # scrollBar = enable; ?
        };
      };
    };
  };
}
