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
        '';
      };

      cp =
        # https://www.alexghr.me/blog/til-nix-flake-fhs/
        # https://ryantm.github.io/nixpkgs/builders/special/fhs-environments/
        # creates a fsh to run random (unpackaged) binarys
        # if i understand correctly its the same as buildFHSUserEnv
        (pkgs.buildFHSEnv
          {
            name = "cmp-prog";
            runScript = pkgs.writeShellScript "cmp-prog-init" ''
              zsh
              name="cmp-prog-env"
              echo "welcome to the cmp-prog-shell"
            '';
            targetPkgs = _pkgs: (with _pkgs; [
              # gcc

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

