{
  my_lib,
  pkgs,
  lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  programs.nixvim = {
    # advanced syntax highliting, but quite surface level
    # (uses a abstract syntax tree)
    extraConfigLua = ''

      -- DO NOT change the paths and don't remove the colorscheme
      local root = vim.fn.fnamemodify('./.repro', ':p')

      -- set stdpaths to use .repro
      for _, name in ipairs { 'config', 'data', 'state', 'cache' } do
        vim.env[('XDG_%s_HOME'):format(name:upper())] = root .. '/' .. name
      end

      -- bootstrap lazy
      local lazypath = root .. '/plugins/lazy.nvim'
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system {
          'git',
          'clone',
          '--filter=blob:none',
          'https://github.com/folke/lazy.nvim.git',
          lazypath,
        }
      end
      vim.opt.runtimepath:prepend(lazypath)

      local plugins = {
        'folke/tokyonight.nvim',
        -- Plugins
        'neovim/nvim-lspconfig',
      }

      require('lazy').setup(plugins, {
        root = root .. '/plugins',
      })

      -- vim.cmd.colorscheme 'tokyonight'

      -- Setup
      local lspconfig = require 'lspconfig'

      vim.lsp.set_log_level(vim.env.NVIM_LSP_LOG_LEVEL or vim.lsp.log_levels.DEBUG)
      require('vim.lsp.log').set_format_func(vim.inspect)

      lspconfig.ruff.setup {}
    '';
  };
}
/*
treesitter = {
  # todo: might want to only install some language parsers
  #   by default it adds all
  enable = true;
  incrementalSelection = enable;
  indent = true;
  nixvimInjections = true;
};

lsp-lines.enable = true;

# static code analysis
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
  /*
  keymaps = {
    diagnostic = {
      "<leader>j" = "goto_next";
      "<leader>k" = "goto_prev";
    };
    lspBuf = {
      K = "hover";
      "<C-k>" = "signature_help";
      gD = "references";
      gd = "definition";
      gi = "implementation";
      gt = "type_definition";
      rn = "rename";
      ca = "code_action";
    };
    silent = true;
  };
*/
/*
servers = {
  nil_ls = enable; # static lsp
  nixd = enable; # eval lsp

  # https://github.com/astral-sh/ruff-lsp#example-neovim
  pyright = {
    enable = false;
    extraOptions = {
      pyright = {
        # Using Ruff's import organizer
        disableOrganizeImports = true;
      };
      python = {
        analysis = {
          # Ignore all files for analysis to exclusively use Ruff for linting
          ignore = ["*"];
        };
      };
    };
  };
  /*

  ruff-lsp = {
    enable = true;
    onAttach.function = ''
      if client.name == 'ruff_lsp' then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
      end
    '';
  };
*/
/*
        ruff = {
          enable = true;
          # https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/ruff.lua
          cmd = [
            "ruff"
            "server"
            "--preview"
            "--config"
            "select = [ \"ALL\" ]"
            # "${./config/ruff.toml}"
          ];
        };

        jsonls = enable;
        html = enable;
        bashls = enable;

        # clangd vs ccls
        # https://github.com/MaskRay/ccls/issues/880
        ccls = enable;

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
  };
}
*/

