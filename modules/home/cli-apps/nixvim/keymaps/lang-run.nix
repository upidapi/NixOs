{lib, ...}: let
  /*
  toAutoCmds = data:
    lib.concatLists (
      builtins.map
      (
        file-data: (
          builtins.concatLists (
            builtins.map
            (bind-data: let
              at = builtins.elemAt bind-data;
              bind = at 0;
              usr_cmd = at 1;

              # code = ":wa<CR>:belowright split | resize 20 | term";
              # :map <buffer> <F9> :wa<CR>:belowright split \| resize 20 \| term python3 %<CR>

              setup_cmd = ''
                # some fuckery to avoid using ' in the command
                # since TermExec seems not to be able to handle that
                PS1="$(printf "\\n>>> ")"

                clear

                # show the run command
                echo -e ">>> $usr_cmd\\n"


                # TODO: make it so that you can click on an error
                #   to jump to it
                #   https://www.reddit.com/r/neovim/comments/gzfb8x/any_idea_on_how_to_make_gf_working_in_the_neovim/

                # TODO: color stderror
                #   https://serverfault.com/questions/59262/bash-print-stderr-in-red-color
                #   export -f color

                color() (
                  set -o pipefail
                  "$@" 2> >(sed $'s,.*,\e[31m&\e[m,'>&2)tree
                )

                eval "color $usr_cmd"

                echo -e "\\nFinished with exit code: $?"
              '';

              lua_thingy = ''
                local command =
                  'usr_cmd=' .. vim.fn.expand([[${usr_cmd}]]) .. ';' ..
                  [[${setup_cmd}]]

                require('toggleterm').exec(command, 1)
              '';

              cmd = "<cmd>wa<CR><cmd>lua ${lua_thingy}<CR>";
            in [
              {
                event = ["FileType"];
                pattern = [file-data.file-type];
                command = "imap <buffer> ${bind} <esc>${cmd}a";
              }
              {
                event = ["FileType"];
                pattern = [file-data.file-type];
                command = "map <buffer> ${bind} ${cmd}";
              }
            ])
            file-data.commands
          )
        )
      )
      data
    );
  */
  toAutoCmds = data:
    lib.concatLists (
      builtins.map
      (
        file-data: (
          builtins.concatLists (
            builtins.map
            (bind-data: let
              at = builtins.elemAt bind-data;
              bind = at 0;
              usr_cmd = at 1;

              # code = ":wa<CR>:belowright split | resize 20 | term";
              # :map <buffer> <F9> :wa<CR>:belowright split \| resize 20 \| term python3 %<CR>

              # we can use expand to emulate the effect of the nvim cmdline
              # i.e

              setup_cmd =
                # major fuckery to avoid using ' in the command
                # since TermExec seems not to be able to handle that
                ''PS1="$(printf "\\n>>> ")";''
                + ''clear;''
                + ''echo -e ">>> ${usr_cmd}\\n";''
                + ''${usr_cmd};''
                + ''echo -e "\\nFinished with code: $?"'';

              term_cmd = ''1TermExec cmd='${setup_cmd}' '';

              cmd = "<cmd>wa<CR><cmd>${term_cmd}<CR>";
            in [
              {
                event = ["FileType"];
                pattern = [file-data.file-type];
                command = "imap ${bind} <esc>${cmd}a";
              }
              {
                event = ["FileType"];
                pattern = [file-data.file-type];
                command = "map ${bind} ${cmd}";
              }
            ])
            file-data.commands
          )
        )
      )
      data
    );
in {
  # https://github.com/ErrorNoInternet/configuration.nix/blob/765d10eb17d733ffb0e596c201c030177135122e/home/programs/terminal/neovim/keymaps/development.nix#L115

  # f9: run, release
  # f10: run, testing, dont resolve deps
  # f11: run, testing
  # f12: create bin, testing
  programs.nixvim.autoCmd = toAutoCmds [
    {
      file-type = "python";
      commands = [
        ["<F9>" "pypy3 %"]
        ["<F11>" "python3 %"]
      ];
    }
    {
      file-type = "c";
      commands = [
        ["<F9>" "clang -O3 -lm % -o %:t:r && ./%:t:r"]
        ["<F11>" "clang -g -lm % -o %:t:r && ./%:t:r"]
        ["<F12>" "clang -g -lm % -o %:t:r"]
      ];
    }
    {
      file-type = "cpp";
      commands = [
        ["<F9>" "clang++ -O3 % -o %:t:r && ./%:t:r"]
        ["<F11>" "clang++ -g % -o %:t:r && ./%:t:r"]
        ["<F12>" "clang++ -g % -o %:t:r"]
      ];
    }
    {
      file-type = "rust";
      commands = [
        ["<F9>" "cd %:p:h:h && cargo run --release"]
        ["<F10>" "rustc -g % && ./%:t:r"]
        ["<F11>" "cd %:p:h:h && cargo run"]
        ["<F12>" "cd %:p:h:h && cargo build"]
      ];
    }
  ];
}
