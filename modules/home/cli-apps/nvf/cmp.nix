{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.binds) mkSetLuaBinding;
  cfg = config.programs.nvf.vim;
in {
  programs.nvf.settings.vim = {
    # had to copy all this just to change {select = true} :)
    maps.insert = let
      defaultKeys =
        if config.vim.autopairs.enable
        then "require('nvim-autopairs').autopairs_cr()"
        else "vim.api.nvim_replace_termcodes(${
          toJSON cfg.autocompleate.mappings.confirm.value
        }, true, false, true)";
    in
      mkSetLuaBinding "<CR>" ''
        function()
          if not require('cmp').confirm({ select = false }) then
            vim.fn.feedkeys(${defaultKeys}, 'n')
          end
        end
      '';

    autocomplete = {
      enable = true;

      alwaysComplete = true;

      # type = "nvim-cmp";

      mapings = {
        complete = "<C-Space>";
        close = "<C-e>";
        confirm = null; # set above

        scrollDocsUp = "<C-d>";
        scrollDocsDown = "<C-f>";

        next = "<Tab>";
        previous = "<S-Tab>";
      };

      sources = map (name: {inherit name;}) [
        "luasnip"
        "treesitter"
        "nvim_lsp"
        "buffer"
        "path"
      ];
    };

    # TODO: luasnip
    # TODO: cmp-calc
  };
}
