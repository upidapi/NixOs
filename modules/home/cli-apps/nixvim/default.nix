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
  cfg = config.modules.home.cli-apps.nixvim;
in {
  imports = [
    # ./../../modules/home
    inputs.nixvim.homeManagerModules.nixvim
    ./lsp.nix
    ./fmt.nix
  ];
  # TODO: what is oil (probably in the nixos filder?
  # TODO: multiple tabs?
  # TODO: fix tab making the lsp throw errors when there is no options
  # TODO: editor regins / folds
  # TODO: skeletion templates and live templates
  # TODO: autocorrect

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

    plugins = {
      lualine = enable;
      lightline = enable;

      # file browser
      neo-tree = enable;

      # autoclose () [] <> "" etc
      autoclose = enable;

      todo-comments = {
        enable = true;

        guiStyle.fg = "BOLD";

        colors = {
          error = ["DiagnosticError" "ErrorMsg" "#DC2626"];
          warning = ["DiagnosticWarn" "WarningMsg" "#FBBF24"];
          info = ["DiagnosticInfo" "#2563EB"];
          hint = ["DiagnosticHint" "#10B981"];
          default = ["Identifier" "#7C3AED"];
          test = ["Identifier" "#FF00FF"];
        };

        highlight = {
          multiline = true; # enable multine todo comments
          # multiline_pattern = "^."; # lua pattern to match the next multiline from the start of the matched keyword
          # multiline_context = 10; # extra lines that will be re-evaluated when changing a line
          before = ""; # "fg" or "bg" or empty
          keyword = "wide"; # "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
          after = "fg"; # "fg" or "bg" or empty
          # pattern = ''.*<(KEYWORDS)\s*:''; # pattern or table of patterns, used for highlighting (vim regex)
          # comments_only = true; # uses treesitter to match keywords in comments only
          # max_line_len = 400; # ignore lines longer than this
          # exclude = []; # list of file types to exclude highlighting
        };

        signs = false;

        keywords = {
          FIX = {
            icon = " "; # Icon used for the sign, and in search results.
            color = "error"; # Can be a hex color, or a named color.
            alt = ["FIXME" "BUG" "FIXIT" "ISSUE"]; # A set of other keywords that all map to this FIX keywords.
          };
          TODO = {
            icon = " ";
            color = "#2563EB";
          };
          HACK = {
            icon = " "; # 󰈸 
            color = "warning";
          };
          WARN = {
            icon = " ";
            color = "warning";
            alt = [
              "WARNING"
              "XXX"
            ];
          };
          PERF = {
            icon = "󰅒 ";
            alt = [
              "OPTIM"
              "PERFORMANCE"
              "OPTIMIZE"
            ];
          };
          NOTE = {
            icon = "󰍩 ";
            color = "hint";
            alt = [
              "INFO"
            ];
          };
          /*
             TEST = {
            icon = "⏲ ";
            color = "test";
            alt = [
              "TESTING"
              "PASSED"
              "FAILED"
            ];
          };
          */
        };
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
