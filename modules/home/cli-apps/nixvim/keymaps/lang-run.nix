{lib, ...}: let
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
                PS1=$"\\n>>> ";
                clear;
                echo -e "${usr_cmd}\\n";
                ${usr_cmd}
              '';

              term_cmd = ''1TermExec cmd='${setup_cmd}' '';

              cmd = "<cmd>wa<CR><cmd>${term_cmd}<CR>";
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
