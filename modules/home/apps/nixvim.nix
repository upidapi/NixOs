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
  # todo: add todo highliting
  # todo: file browser
  # todo: what is oil (probably in the nixos filder?
  # todo: multiple tabs?
  # todo: fix tab making the lsp throw errors when there is no options

  options.modules.home.apps.nixvim =
    mkEnableOpt "enables nixvim";

  # btw ctrl-w + v splits window vertically
  # btw ctrl-w + s splits window horizintaly
  # btw ctrl-w + q closes window

  # todo: place "less" in it's own module (probably in the nixos filder)
  config.home = {
    packages = [
      pkgs.less
    ];

    sessionVariables = {
      PAGER = "less";
      MANPAGER = "less";
      EDITOR = "nvim";
    };
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

      nvim-cmp = {
        enable = true;

        autoEnableSources = true;
        sources = [
          {name = "path";}
          {name = "treesitter";}
          {name = "nvim_lsp";}
          {name = "buffer";}
          {name = "luasnip";}
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
