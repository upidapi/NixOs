{
  config,
  inputs,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (my_lib.opt) enable disable;
  inherit (inputs.nvf.lib.nvim.binds) mkBinding;
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
  cfg = config.modules.home.cli-apps.nvf;
in {
  imports = [
    ./cmp.nix
    ./dap.nix
    ./text.nix
    ./lang.nix
    ./notes.nix
  ];

  config = mkIf cfg.enable {
    programs.nvf = {
      settings.vim = {
        # ? syntaxHighlighting = true;
        hideSearchHighlight = false; # ?
        searchCase = "sensitive";
        # ? showSignColumn = false

        splitRight = true;
        lineNumberMode = "relNumber";
        wordWrap = true;

        tabWidth = 4;

        # n	Normal mode
        # v	Visual mode
        # i	Insert mode
        # c	Command-line mode
        # h	all previous modes when editing a help file
        # a	all previous modes
        # r	for hit-enter and more-prompt prompt
        # TODO: submit pr since options only allow for single char
        # mouseSupport = "nvchr";
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

        filetree = {
          # TODO: neo-tree or nvimTree ?
          #  nvimTree has a lot better support (1.5k lines of docs lol)
          neo-tree = {
            enable = true;
            setupOpts = {
              window.width = 30;
            };
          };
        };

        # TODO: neorg
        # https://github.com/Soliprem/nix-config/blob/main/home-manager/nvim.nix

        # git intergration
        # TODO: binds?
        git.vim-fugitive = enable;

        lsp = {
          enable = true;
          formatOnSave = false;

          # TODO: config this?
          # lightbulb = enable;

          # TODO: config this?
          lspSignature = enable;

          # already enabled by lang.nix
          # lspconfig = enable;

          # pictograms for lsp options
          lspkind = enable;

          # inline lsp diagnostics
          # lsplines = enable;

          # TODO: binds
          # TODO: remove this?
          #  its probably unecisary
          # lspsaga = enable;

          # enabled automatically
          # null-ls = enable;

          mappings = {
            # TODO:
          };

          # trouble = enable;
        };

        notify = {
          # ? nvim-notify = enable;
        };
        # ASD

        projects.project-nvim = enable;

        snippets = {
          # TODO: luasnip
        };

        luaConfigRC.spell-extra = entryAnywhere ''
          vim.o.spelloptions = "camel";
        '';

        spellcheck = {
          enable = true;
          languages = ["en" "sv"];
          # TODO: programmingWordlist = enable;
          # i.e. vim-dirtytalk = enable;
        };

        statusline = {
          lualine = enable;
          # TODO: config
        };

        # tabline = {
        #   nvimBufferline = {
        #     enable = true;
        #     mappings = {
        #       # TODO:
        #     };
        #   };
        # };

        maps.normal = mkMerge [
          (
            mkBinding
            "<leader>fz"
            "Telescope current_buffer_fuzzy_find"
            "telescope fuzzy find"
          )

          # neo tre
          (mkBinding "<leader>tt" "Neotree toggle" "toggle neo-tree")
          (mkBinding "<leader>tu" "Neotree" "goto neo-tree")
          (mkBinding "<leader>tr" "Neotree reveal" "show self in neo-tree")
        ];

        telescope = {
          enable = true;
          mappings = {
            findProjects = "<leader>fp"; # "<leader>fp";
            findFiles = "<leader>ff"; # "<leader>ff";
            buffers = "<leader>fb"; # "<leader>fb";

            liveGrep = "<leader>"; # "<leader>fg";
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

        theme = {
          enable = true;
          name = "tokyonight";
          transparent = false;
          style = "moon"; # maybe storm or night
        };

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

        ui = {
          borders = disable;
          breadcrumbs = disable;

          colorizer = enable;
          illuminate = disable;

          # alternative ui
          # noice = enable;

          smartcolumn = {
            enable = true;
            setupOpts.colorcolumn = ["80" "100"];
          };
        };

        utility = {
          ccc = {
            enable = true;
            mappings = {
              decrease10 = "<H>";
              increase10 = "<L>";
              quit = "<Esc>";
            };
          };

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

          cursorline = enable;

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
