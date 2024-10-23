{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (inputs.nvf.lib.nvim.binds) mkLuaBinding;
  cfg = config.programs.nvf.settings.vim;
in {
  programs.nvf.settings.vim = {
    # had to copy all this just to change {select = true} :)
    maps.insert = let
      defaultKeys =
        if cfg.autopairs.enable
        then "require('nvim-autopairs').autopairs_cr()"
        else "vim.api.nvim_replace_termcodes(${
          toJSON cfg.autocomplete.mappings.confirm.value
        }, true, false, true)";
    in
      mkLuaBinding "<CR>" ''
        function()
          if not require('cmp').confirm({ select = false }) then
            vim.fn.feedkeys(${defaultKeys}, 'n')
          end
        end
      '' "confirm cmp completion";

    autocomplete = {
      enable = true;

      alwaysComplete = true;

      type = "nvim-cmp";

      mappings = {
        complete = "<C-Space>";
        close = "<C-e>";
        confirm = null; # set above

        scrollDocsUp = "<C-d>";
        scrollDocsDown = "<C-f>";

        next = "<Tab>";
        previous = "<S-Tab>";
      };

      /*
      sources = builtins.listToAttrs (map (x: {
          name = x;
          value = x;
        }) [
          "luasnip"
          # "treesitter"
          # "nvim_lsp"
          # "buffer"
          # "path"
        ]);
      */
    };

    # TODO: cmp-calc
  };
}
