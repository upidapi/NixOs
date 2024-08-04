{
  config,
  lib,
  inputs,
  pkgs,
  my_lib,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.binds) mkSetLuaBinding;
  inherit (my_lib.opt) enable;
  cfg = config.programs.nvf.vim;
in {
  programs.nvf.settings.vim = {
    # there are more debuggers in the lang(s)
    debugger = {
      nvim-dap = {
        enable = true;

        ui = enable;

        # what does this do?
        sources = {};

        mappings = {
          continue = "<leader>dc";
          restart = "<leader>dR";
          terminate = "<leader>dq";
          runLast = "<leader>d.";

          toggleRepl = "<leader>dr";
          hover = "<leader>dh";
          toggleBreakpoint = "<leader>db";

          runToCursor = "<leader>dC";
          stepOver = "<leader>dj"; # next statement
          stepBack = "<leader>dk"; # previous statement

          stepInto = "<leader>di";
          stepOut = "<leader>do";

          goUp = "<leader>dvo";
          goDown = "<leader>dvi";

          toggleDapUI = "<leader>du";
        };
      };
    };
  };
}
