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
  ];
  # todo: add todo highliting
  # todo: better file browser
  # todo: what is oil (probably in the nixos filder?
  # todo: multiple tabs?
  # todo: fix tab making the lsp throw errors when there is no options
  # todo: editor regins / folds
  # todo: fix the cmp sources

  options.modules.home.cli-apps.nixvim =
    mkEnableOpt "enables nixvim";

  # does this get saved

  # btw ctrl-w + v splits window vertically
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

      # advanced syntax highliting, but quite surface level
      # (uses a abstract syntax tree)
      treesitter = {
        # todo: might whant to only install some language parsers
        #   by default it adds all
        enable = true;
      };

      # code compleation
      lsp = {
        enable = true;

        # "barrowed"
        # i think it makes the lsp run while typing
        postConfig = ''
          vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
            vim.lsp.diagnostic.on_publish_diagnostics, {
              update_in_insert = true,
            }
          )
        '';

        servers = {
          nil_ls = enable; # nix
          pylsp = enable; # python
          jsonls = enable;
          html = enable;
          bashls = enable;

          # lua
          lua-ls = {
            enable = true;
            settings.telemetry.enable = false;
          };

          # # rust
          # rust-analyzer = {
          # enable = true;
          # installCargo = true;
          # };
        };
      };

      cmp = {
        enable = true;

        autoEnableSources = true;
        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          sources = map (name: {inherit name;}) [
           "path"
           "treesitter"
           "nvim_lsp"
           "buffer"
           "luasnip"
          ];

        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expandable() then
                  luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                elseif check_backspace() then
                  fallback()
                else
                  fallback()
                end
              end
            '';
            modes = ["i" "s"];
          };
        };
        };

        cmdline =
          (builtins.listToAttrs
            (map
              (name: {
                inherit name;
                value.sources = [{name = "buffer";}];
              })
              ["/" "?"]
            )
          ) // {
            ":".sources = [
              {name = "path";}
            ];
          };
      };

      cmp-calc.enable = true;
      cmp-treesitter.enable = true;
      cmp_luasnip.enable = true;
      luasnip = {
        enable = true;
        fromVscode = [{}];
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
