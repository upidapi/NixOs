{
  config,
  lib,
  inputs,
  my_lib,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.binds) mkSetLuaBinding;
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
  inherit (my_lib.opt) enable;
  inherit (lib) boolToString;
  cfg = config.programs.nvf.settings.vim;
in {
  programs.nvf.settings.vim = {
    pluginRC.autopairs =
      /*
      lua
      */
      # add "entryAnywhere" here?
      entryAnywhere ''
        local npairs = require("nvim-autopairs")
        npairs.setup({ map_cr = ${boolToString (!cfg.autocomplete.enable)} })

        local Rule = require('nvim-autopairs.rule')

        npairs.add_rules({
          Rule("/*", "*/", {"javascript", "typescript", "nix"}),
        })
      '';

    autopairs = enable;

    comments = {
      comment-nvim = {
        enable = true;
        mappings = {
          # TODO: change binds
          toggleCurrentLine = "gcc";
          toggleCurrentBlock = "gbc";

          toggleOpLeaderLine = "gc";
          toggleOpLeaderBlock = "gb";

          toggleSelectedLine = "gc";
          toggleSelectedBlock = "gb";
        };
      };
    };
  };
}
