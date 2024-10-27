{my_lib, ...}: let
  inherit (my_lib.opt) enable;
in {
  programs.nvf.settings.vim = {
    # there are more debuggers in the lang(s)
    debugger = {
      nvim-dap = {
        enable = true;

        ui = enable;

        # what does this do?
        sources = {};
      };
    };
  };
}
