let
  mkMultiCmd = {
    key,
    action,
    override ? {},
  }: [
    ({
        mode = "n";
        options.silent = true;
        key = key;
        action = "${action}<CR>";
      }
      // override)
    ({
        mode = "i";
        options.silent = true;
        key = key;
        action = "<esc><cmd>${action}<CR>a";
      }
      // override)
  ];

  mkMultiCmds = data: (
    builtins.concatLists
    (
      builtins.map
      (
        sub_data:
          mkMultiCmd (
            if builtins.typeOf sub_data == "set"
            then sub_data
            else {
              key = builtins.elemAt sub_data 0;
              action = builtins.elemAt sub_data 1;
            }
          )
      )
      data
    )
  );
in {
  programs.nixvim = {
    keymaps =
      []
      ++ mkMultiCmds [
        ["<F1>" "xa"]
        ["<F2>" "wa"]
        # ["<F3>" ":lua require('conform').format()"]
      ];
  };
}
