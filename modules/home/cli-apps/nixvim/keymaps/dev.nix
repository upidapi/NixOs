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

  strToChars = s: builtins.genList (p: builtins.substring p 1 s) (builtins.stringLength s);

  mkMultiCmd = {
    modes,
    key,
    action,
    override ? {},
  }:
    builtins.map
    (mode:
      mkCmd {
        inherit mode;
        inherit key;
        inherit action;
        inherit override;
      })
    (strToChars modes);

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
              modes = builtins.elemAt sub_data 0;
              key = builtins.elemAt sub_data 1;
              action = builtins.elemAt sub_data 2;
            }
          )
      )
      data
    )
  );

  prependList = pre: things:
    builtins.map
    (thing: [pre] ++ thing)
    things;
in {
  programs.nixvim = {
    keymaps =
      []
      ++ mkMultiCmds (
        (prependList "ni" [
          ["<F1>" "xa"]
          ["<F2>" "wa"]
          ["<F3>" ":lua require('conform').format()"]
        ])
        ++ (prependList "n" [
          # dap
          ["<leader>db" "DapToggleBreakpoint"]
          ["<leader>dt" "DapTerminate"]
          ["<leader>dc" "DapContinue"]
          ["<leader>di" "DapStepInto"]
          ["<leader>do" "DapStepOut"]
          ["<leader>dv" "DapStepOver"]

          # neotree
          ["<leader>tt" "Neotree toggle"]
          ["<leader>tu" "Neotree"] # neotree update
          ["<leader>tr" "Neotree reveal"] # neotree update

          # telescope
          ["<leader>ft" "TodoTelescope"]
          ["<leader>fc" "Telescope git_bcommits"]
          ["<leader>fC" "Telescope git_commits"]
          ["<leader>fb" "Telescope buffers"]
          ["<leader>ff" "Telescope find_files"]
          ["<leader>fg" "Telescope live_grep"]
          ["<leader>fz" "Telescope current_buffer_fuzzy_find"]

          # c-j
          # ufo (ultra fold)
          ["zr" "foldopen"]
          ["zm" "foldclose"]
          ["zR" "lua require('ufo').openAllFolds()"]
          ["zM" "lua require('ufo').closeAllFolds()"]

          # hot reload related
          [
            "<leader>sl"
            "wa | source $NIXOS_CONFIG_PATH/modules/home/cli-apps/nixvim/luasnip.lua"
          ]
        ])
      );

    extraConfigLua =
      /*
      lua
      */
      ''
        -- luasnip
        vim.keymap.set({ "i", "s" }, "<c-k>", function()
          if ls.expand_or_jumpable() then
            ls.expand_or_jump()
          end
        end, { silent = true })

        vim.keymap.set({ "i", "s" }, "<c-j>", function()
          if ls.jumpable(-1) then
            ls.jump(-1)
          end
        end, { silent = true })

        vim.keymap.set({ "i", "s" }, "<c-l>", function()
          if ls.choice_active() then
            ls.change_choice(1)
          end
        end)
      '';
  };
}
