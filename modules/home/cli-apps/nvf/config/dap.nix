{my_lib, ...}: let
  inherit (my_lib.opt) enable;
in {
  programs.nvf.settings.vim = {
    # there are more debuggers in the lang(s)
    debugger = {
      nvim-dap = {
        enable = true;

        # done in lua
        # ui = enable;

        # what does this do?
        sources = {};

        mappings = {
          # continue = null; -- breaks (errors) rust.nix (in nvf)
          restart = null;
          terminate = null;
          runLast = null;

          toggleRepl = null;
          hover = null;
          toggleBreakpoint = null;

          runToCursor = null;
          stepInto = null;
          stepOut = null;
          stepOver = null;
          stepBack = null;

          goUp = null;
          goDown = null;

          toggleDapUI = null;
        };
      };
    };
  };
}
