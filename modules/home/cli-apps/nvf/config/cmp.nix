{
  programs.nvf.settings.vim = {
    # had to copy all this just to change {select = true} :)
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
    };
  };
}
