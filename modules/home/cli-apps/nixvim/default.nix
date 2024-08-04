{
  config,
  inputs,
  lib,
  my_lib,
  # pkgs,
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
    ./fmt.nix
    ./keymaps
    ./lsp.nix
    ./todo-comments.nix
  ];

  # TODO: what is oil (probably in the nixos filder?
  # TODO: multiple tabs?
  # TODO: might switch away from the nixvim options
  #  instead use it for pkgs management, but use extraLuaConfig for everything else

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

    # use system clipboard instead of internal registers
    # clipboard.register = "unnamedplus";

    colorschemes.tokyonight = enable;

    # vimAlias = true;

    opts = {
      relativenumber = true; # Show relative line numbers
      number = true; # Show line numbers

      encoding = "utf8";
      expandtab = true;
      modeline = false;
      shiftwidth = 4;

      # disable mouse (prevent acedental while typing)
      mouse = "";

      # https://stackoverflow.com/questions/35156448/autoindent-smartindent-and-indentexpr
      # https://stackoverflow.com/questions/11121191/how-not-to-remove-indentation-by-inserting
      # made for c style langs (eg removes indent if you press #)
      # smartindent = true;

      softtabstop = 4;
      swapfile = false;

      tabstop = 4;

      showcmd = true; # Show incomplete cmds down the bottom
      # colorcolumn="80"; # show a ruler at col 80

      # for ufo
      foldcolumn = "0"; #  '0' is not bad
      foldlevel = 100; # Using ufo provider need a large value, feel free to decrease the value
      foldlevelstart = 100;
      foldenable = true;

      # TODO: fix spelling
      # spell = true;
      # spelllang = "en,ckj";
      # spelloptions = "camel";
    };

    /*
    extraPlugins = [
      # adds the "programming" dict for spellchecking asd
      (pkgs.vimUtils.buildVimPlugin {
        pname = "vim-dirtytalk";
        version = "2024-07-10"
        src = pkgs.fetchFromGitHub {
          owner = "psliwka";
          repo = "vim-dirtytalk";
          rev = "aa57ba902b04341a04ff97214360f56856493583";
          hash = "sha256-azU5jkv/fD/qDDyCU1bPNXOH6rmbDauG9jDNrtIXc0Y=";
        };
      })
    ];
    */

    globals = {
      mapleader = " ";
      # maplocalleader = "\\<Space>";
    };

    plugins = {
      # notes
      neorg = enable;

      # image support
      image = enable;

      toggleterm = {
        enable = true;
      };

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
        providerSelector =
          /*
          lua
          */
          ''
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

                return {'lsp', 'indent'}
            end
          '';
      };

      # finding stuff
      telescope = enable;

      # better copying
      # yanky = enable
    };

    # autoclose () [] <> "" etc
    # autoclose = enable;
    plugins.nvim-autopairs = enable;

    extraConfigLua =
      /*
      lua


      */
      ''
        local npairs = require("nvim-autopairs")
        local Rule = require('nvim-autopairs.rule')

        npairs.add_rules({
          Rule("/*", "*/", {"javascript", "typescript", "nix"}),
        })
      '';

    filetype.pattern = {
      ".*/hyprland%.conf" = "hyprlang";
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
