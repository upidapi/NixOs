{
  programs.nixvim = {
    keymaps = [
      # formatt file
      {
        # mode = ["n" "i"];
        options.silent = true;
        key = "<F1>";
        action = ":xa<CR>";
      }
      {
        # mode = ["n" "i"];
        # options.silent = true;
        key = "<F2>";
        action = ":wa";
      }
      {
        # mode = ["n" "i"];
        options.silent = true;
        key = "<F3>";
        action = ":lua require('conform').format()";
      }
    ];
  };
}
