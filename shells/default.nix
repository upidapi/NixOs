{...}: {
  perSystem = {pkgs, ...}: {
    devShells = {
      default = pkgs.mkShell {
        packages = [
          (
            pkgs.python3.withPackages (
              py-pkgs:
                with py-pkgs; [
                  pandas
                  requests
                  pwntools
                ]
            )
          )
        ];

        shellHook = ''
          zsh
          exit
        '';
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
              zsh
            '';
            targetPkgs = _pkgs: (with _pkgs; [
              # gcc

              # forensics
              imhex # hex editor
              audacity # audio foresics (and editor)
              binwalk
              file
              ltrace
              strace

              # binary decompilation
              ghidra
              radare2
              # TODO: binary ninja

              sqlmap # sql injection

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

