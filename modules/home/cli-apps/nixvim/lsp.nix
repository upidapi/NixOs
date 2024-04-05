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

    # code compleation
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
          "<C-Space>" = "cmp.mapping.complete()";
          "<C-d>" = "cmp.mapping.scroll_docs(-4)";
          "<C-e>" = "cmp.mapping.close()";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
        };
      };

      cmdline =
        (
          builtins.listToAttrs
          (
            map
            (name: {
              inherit name;
              value.sources = [{name = "buffer";}];
            })
            ["/" "?"]
          )
        )
        // {
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
}
