{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.binds) mkSetLuaBinding;
  cfg = config.programs.nvf.vim;
in {
  programs.nvf = {
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

    settings.vim = {
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
  };
}
