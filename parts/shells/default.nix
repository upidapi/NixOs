{
  config,
  inputs,
  lib,
  # , pkgs
  ...
} @ args: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    devShells = {
      default = pkgs.mkShell {
        packages = [
          (
            pkgs.python3.withPackages (
              py-pkgs:
                with py-pkgs; [
                  pyyaml

                  pandas
                  requests

                  dbus-python
                  pygobject3

                  pillow

                  beautifulsoup4
                ]
            )
          )
        ];

        shellHook = ''
          exec zsh
        '';
      };

      # for debugging
      nvim = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.nixd
          # pkgs.nixfmt-rfc-style
          pkgs.git
          (import ./nvim-lsp.nix {inherit pkgs;})
        ];
      };

      /*
      nvf = let
        n = inputs.nvf.lib.neovimConfiguration {
          modules = [
            {
              # Add any custom options (and do feel free to upstream them!)
              # options = { ... };

              config.vim =
                (import ./nvf.nix (args // {inherit pkgs;}))
                // {
                  # theme.enable = true;
                  # and more options as you see fit...

                  startPlugins = with pkgs.vimPlugins; [
                    (nvim-treesitter.withPlugins (
                      parsers: builtins.attrValues {inherit (parsers) nix markdown markdown_inline;}
                    ))
                    friendly-snippets
                    luasnip
                    nvim-cmp
                    cmp-nvim-lsp
                    cmp-buffer
                    cmp_luasnip
                    cmp-path
                    cmp-cmdline
                    none-ls-nvim
                    nvim-lspconfig
                    nord-nvim
                    noice-nvim
                    lualine-nvim
                    bufferline-nvim
                    lspsaga-nvim
                  ];

                  luaConfigRC."lua-cfg" =
                    builtins.readFile
                    ../../modules/home/cli-apps/nvf/lua/cmp.lua;
                  #"${self}/modules/home/"
                };
            }
          ];
          inherit pkgs;
        };
      in
        pkgs.mkShell {
          nativeBuildInputs = [
            (pkgs.runCommand "nvf-lsp" {} ''
              mkdir -p $out/bin
              ln -s ${n.neovim}/bin/nvim $out/bin/nvf-lsp
            '')
          ];
        };
      */

      kattis = pkgs.mkShell {
        packages = [
          self'.packages.problem-tools
        ];
      };

      # TODO: fix ldconfig: file /nix/store... .so is truncated
      #  error / notification when entering fhs env
      #  https://github.com/NixOS/nixpkgs/issues/352717
      # test =
      #   (pkgs.buildFHSEnv
      #     {
      #       name = "cmp-prog-fhs";
      #       runScript = pkgs.writeShellScript "cmp-prog-init" ''
      #         name="cmp-prog-fhs"
      #         exec zsh
      #       '';
      #       targetPkgs = _pkgs: (with _pkgs; [
      #         ]);
      #     })
      #   .env;

      sec =
        # https://www.alexghr.me/blog/til-nix-flake-fhs/
        # https://ryantm.github.io/nixpkgs/builders/special/fhs-environments/
        # creates a fsh to run random (unpackaged) binarys
        # if i understand correctly its the same as buildFHSUserEnv
        (pkgs.buildFHSEnv
          {
            name = "cmp-prog-fhs";
            runScript = pkgs.writeShellScript "cmp-prog-init" ''
              name="cmp-prog-fhs"
              exec zsh
            '';
            targetPkgs = _pkgs: (with _pkgs; [
              # forensics
              imhex
              binwalk
              file
              audacity
              gnuradio
              wireshark

              # hardware
              tio

              # pwn
              # EXPLORE: formatStringExploiter
              # EXPLORE: libformatstr
              pwninit
              checksec

              # rev
              gdb
              gef # gef extensions
              pwndbg # gef extensions

              radare2

              # EXPLORE: apktool and android rev in general
              ghidra
              # android / apk
              apktool
              dex2jar

              # java decompilers
              # https://kalilinuxtutorials.com/apk-sh/
              # there is no longer a source for the upstream dep
              # jd-cli
              # jd-gui

              # seams to be functionally objectively worse than jq-cli/gui
              # jadx
              cfr
              # procyon
              # bytecode-viewer

              strace
              ltrace

              # web
              burpsuite
              zap

              mitmproxy
              sqlmap

              # for compatibility
              udev
              alsa-lib

              # crypto
              sage

              (python3.withPackages (
                python-pkgs:
                  with python-pkgs; [
                    pycrypto
                    requests
                    pwntools
                    pillow
                    beautifulsoup4
                    pyyaml
                  ]
              ))
            ]);
          })
        .env;
    };
  };
}
/*
# example

{self, ...}: {
imports = [
./rust.nix
./sandbox.nix
];

perSystem = {
inputs',
pkgs,
self',
system,
...
}: {
devShells.default = pkgs.mkShell {
name = "configuration.nix";
packages = let
customPkgs = import ../packages {
    inherit inputs' pkgs self system;
};
in
[
    inputs'.agenix.packages.default
    inputs'.disko.packages.default
    self'.formatter
]
++ (
    with customPkgs; [
      delta
      neovim-unwrapped
      nix
      tmux
    ]
)
++ (
    with pkgs; [
      bat
      deadnix
      git
      nix-output-monitor
      parted
      smartmontools
      statix
    ]
);
};
};
*/

