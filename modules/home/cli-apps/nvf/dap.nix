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
          continue = "Contiue" "<leader>dc";
          restart = "Restart" "<leader>dR";
          terminate = "Terminate" "<leader>dq";
          runLast = "Re-run Last Debug Session" "<leader>d.";

          toggleRepl = "Toggle Repl" "<leader>dr";
          hover = "Hover" "<leader>dh";
          toggleBreakpoint = "Toggle breakpoint" "<leader>db";

          runToCursor = "Continue to the current cursor" "<leader>dC";
          stepOver = "Next step" "<leader>dj"; # next statement
          stepBack = "Step back" "<leader>dk"; # previous statement

          stepInto = "Step into function" "<leader>di";
          stepOut = "Step out of function" "<leader>do";

          goUp = "Go up stacktrace" "<leader>dvo";
          goDown = "Go down stacktrace" "<leader>dvi";

          toggleDapUI = "Toggle DAP-UI" "<leader>du";
        };
      };
    };
  };
}
