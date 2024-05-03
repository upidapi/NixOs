{my_lib, ...}: let
  inherit (my_lib.opt) enable;
in {
  programs.nixvim.plugins = {
    # advanced syntax highliting, but quite surface level
    # (uses a abstract syntax tree)
    treesitter = {
      # todo: might whant to only install some language parsers
      #   by default it adds all
      enable = true;
      incrementalSelection = enable;
      indent = true;
      nixvimInjections = true;
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

      servers = {
        nil_ls = enable; # static lsp
        nixd = enable; # eval lsp

        pyright = enable; # python
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
