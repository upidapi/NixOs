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
              # crypto
              sage

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

              strace
              ltrace

              # web
              # TODO: burp suite or opensource alt
              sqlmap

              # for compatibility
              udev
              alsa-lib

              (python3.withPackages (
                python-pkgs:
                  with python-pkgs; [
                    pycrypto
                    requests
                    pwntools
                    pillow
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

