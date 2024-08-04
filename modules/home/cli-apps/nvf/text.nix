{
  config,
  lib,
  inputs,
  my_lib,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.binds) mkSetLuaBinding;
  inherit (my_lib.opt) enable;
  cfg = config.programs.nvf.vim;
in {
  programs.nvf.settings.vim = {
    pluginRC.autopairs =
      /*
      lua
      */
      # add "entryAnywhere" here?
      ''
        local npairs = require("nvim-autopairs")
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
