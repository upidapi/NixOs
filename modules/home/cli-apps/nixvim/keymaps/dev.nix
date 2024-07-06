let
  mkCmd = {
    mode,
    key,
    action,
    override ? {},
  }: let
    actions = {
      n = "<cmd>${action}<CR>";
      i = "<esc><cmd>${action}<CR>a";
    };
  in ({
      mode = mode;
      options.silent = true;
      key = key;
      action = actions."${mode}";
    }
    // override);

  mkMultiCmd = {
    # modes,
    key,
    action,
    override ? {},
  }: [
    (mkCmd
      {
        mode = "n";
        inherit action;
        inherit override;
        inherit key;
      })
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
        /*
        ["<F1>" "xa"]
        ["<F2>" "wa"]
        ["<F3>" ":lua require('conform').format()"]

        # dap
        ["<leader>db" "DapToggleBreakpoint"]
        ["<leader>dt" "DapTerminate"]
        ["<leader>dc" "DapContinue"]
        ["<leader>di" "DapStepInto"]
        ["<leader>do" "DapStepOut"]
        ["<leader>dv" "DapStepOver"]

        # neotree
        ["<leader>t" "Neotree toggle"]
        # ["<leader>fu" "Neotree"]  # neotree update

        # telescope
        ["<leader>ft" "TodoTelescope"]
        ["<leader>fc" "Telescope git_bcommits"]
        ["<leader>fC" "Telescope git_commits"]
        ["<leader>fb" "Telescope buffers"]
        ["<leader>ff" "Telescope find_files"]
        ["<leader>fg" "Telescope live_grep"]
        ["<leader>fz" "Telescope current_buffer_fuzzy_find"]
        */
      ];
  };
}
