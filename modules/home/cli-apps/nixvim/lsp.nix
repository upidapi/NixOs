{
  my_lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      nvim-lspconfig
    ];
    plugins = {
      # advanced syntax highliting, but quite surface level
      # (uses a abstract syntax tree)
      treesitter = {
        enable = true;
        settings = {
          incremental_selection = enable;
          indent = enable;
        };
        nixvimInjections = true;
      };

      lsp-lines.enable = true;
      typescript-tools = {
        enable = true;
        settings = {
          exposeAsCodeAction = "all";
        };
      };

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
        servers = {
          nil-ls = enable; # static lsp
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
          tsserver = enable;

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
  };
}
