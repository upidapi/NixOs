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
  # TODO add todo highliting
  # TODO better file browser
  # TODO what is oil (probably in the nixos filder?
  # TODO multiple tabs?
  # TODO fix tab making the lsp throw errors when there is no options
  # TODO editor regins / folds
  # TODO fix the cmp sources
  # TODO skeletion templates and live templates
  # TODO autocorrect

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

    extraPlugins = [pkgs.vimPlugins.gruvbox];
    colorscheme = "gruvbox";

    # colorschemes.gruvbox = enable;

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
        keywords = {
          FIX = {
            icon = "<U+F188> "; # Icon used for the sign, and in search results.
            color = "error"; # Can be a hex color, or a named color.
            alt = ["FIXME" "BUG" "FIXIT" "ISSUE"]; # A set of other keywords that all map to this FIX keywords.
          };
          TODO = {
            icon = "<U+F00C> ";
            color = "info";
          };
          HACK = {
            icon = "<U+F490> ";
            color = "warning";
          };
          WARN = {
            icon = "<U+F071> ";
            color = "warning";
            alt = [
              "WARNING"
              "XXX"
            ];
          };
          PERF = {
            icon = "<U+F651> ";
            alt = [
              "OPTIM"
              "PERFORMANCE"
              "OPTIMIZE"
            ];
          };
          NOTE = {
            icon = "<U+F867> ";
            color = "hint";
            alt = [
              "INFO"
            ];
          };
          TEST = {
            icon = "⏲ ";
            color = "test";
            alt = [
              "TESTING"
              "PASSED"
              "FAILED"
            ];
          };
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
