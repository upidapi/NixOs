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
              cmd = at 1;
            in [
              {
                event = ["FileType"];
                pattern = [file-data.file-type];
                command = "imap <buffer> ${bind} <esc>:wa<CR>:term ${cmd}<CR>";
              }
              {
                event = ["FileType"];
                pattern = [file-data.file-type];
                command = "map <buffer> ${bind} :wa<CR>:term ${cmd}<CR>";
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

  /*
  f8: run, release
  f9: run, testing, dont resolve deps
  f10: run, testing
  f11: create bin, testing
  */

  programs.nixvim.autoCmd = toAutoCmds [
    {
      file-type = "python";
      commands = [
        ["<F8>" "pypy3 %"]
        ["<F10>" "python3 %"]
      ];
    }
    {
      file-type = "c";
      commands = [
        ["<F8>" "clang -O3 -lm % -o %:t:r && ./%:t:r"]
        ["<F10>" "clang -g -lm % -o %:t:r && ./%:t:r"]
        ["<F11>" "clang -g -lm % -o %:t:r"]
      ];
    }
    {
      file-type = "cpp";
      commands = [
        ["<F8>" "clang++ -O3 % -o %:t:r && ./%:t:r"]
        ["<F10>" "clang++ -g % -o %:t:r && ./%:t:r"]
        ["<F11>" "clang++ -g % -o %:t:r"]
      ];
    }
    {
      file-type = "rust";
      commands = [
        ["<F8>" "cd %:p:h:h && cargo run --release"]
        ["<F9>" "rustc -g % && ./%:t:r"]
        ["<F10>" "cd %:p:h:h && cargo run"]
        ["<F11>" "cd %:p:h:h && cargo build"]
      ];
    }
  ];
}
