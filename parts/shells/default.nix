{
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

      kattis = pkgs.mkShell {
        packages = [
          self'.packages.problem-tools
        ];
      };

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
              gef
              # EXPLORE: apktool and android rev in general
              ghidra
              radare2
              # android / apk
              apktool
              dex2jar
              # java decompilers
              # https://kalilinuxtutorials.com/apk-sh/
              jd-cli
              jd-gui
              # seams to be functionally objectively worse
              # jadx
              # cfr

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
}
*/

