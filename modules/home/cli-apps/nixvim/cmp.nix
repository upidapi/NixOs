{
  programs.nixvim = {
    plugins = {
      # code compleation
      cmp = {
        enable = true;

        autoEnableSources = true;
        settings = {
          snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          # we might be able to use ‘plugins.cmp.autoEnableSources’ instead
          sources = map (name: {inherit name;}) [
            "luasnip"
            "treesitter"
            "nvim_lsp"
            "buffer"
            "path"
          ];

          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = false })";
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
        # fromLua = [{paths = ./snippets;}];
        # fromVscode = [{}];
        extraConfig = {
          history = true;

          updateevents = "TextChanged,TextChangedI";

          #enable_autosnippets = true;

          /*
          ext_opts = {
            "types.choiceNode" = {
              active = {virt_text = [["<-" "Error"]];};
            };
          };
          */
        };
      };
    };
    extraConfigLua = builtins.readFile ./luasnip.lua;
  };
}
