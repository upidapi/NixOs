{
  # config,
  inputs,
  # lib,
  self,
  # , pkgs
  ...
}
/*
@ args
*/
: {
  perSystem = {
    # pkgs,
    self',
    inputs',
    system,
    ...
  }: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
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
          exec $SHELL
        '';
      };

      # a devshell that builds and opens an editor with the current mnw
      # (neovim) config
      # nix develop /persist/nixos#mnw -c bash -c "nvim /persist/nixos; exit"
      #
      mnw = pkgs.mkShellNoCC {
        # shellHook = ''
        #   cd /persist/nixos/modules/home/cli-apps/neovim/lua/
        #   nvim .
        #   exit
        # '';
        packages = [
          self.nixosConfigurations.upinix-pc.config.home-manager.users.upidapi.programs.mnw.finalPackage
        ];
      };

      kattis = pkgs.mkShell {
        packages = [
          self'.packages.problem-tools
        ];
      };

      fhs =
        (pkgs.buildFHSEnv
          {
            name = "cmp-prog-fhs";
            runScript = pkgs.writeShellScript "cmp-prog-init" ''
              name="cmp-prog-fhs"
              exec nu
            '';
          })
        .env;

      ai = let
        cuda-pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };
        # REF: https://lavafroth.is-a.dev/post/cuda-on-nixos-without-sacrificing-ones-sanity/#the-flake
      in
        (cuda-pkgs.buildFHSEnv {
          name = "nvidia-fuck-you";
          targetPkgs = pkgs: (with pkgs; [
            (python3.withPackages (ps:
              with ps; [
                torchvision
                matplotlib
                numpy
                mlflow
                pytorch
              ]))

            linuxPackages.nvidia_x11
            libGLU
            libGL
            xorg.libXi
            xorg.libXmu
            freeglut
            xorg.libXext
            xorg.libX11
            xorg.libXv
            xorg.libXrandr
            zlib
            ncurses5
            stdenv.cc
            binutils
            ffmpeg

            # Micromamba does the real legwork
            micromamba
          ]);

          profile = ''
            export LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib"
            export CUDA_PATH="${pkgs.cudatoolkit}"
            export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
            export EXTRA_CCFLAGS="-I/usr/include"
          '';

          # again, you can remove this if you like bash
          runScript = pkgs.writeShellScript "cmp-prog-init" ''
            name="cmp-prog-fhs"
            exec nu
          '';
        })
        .env;

      # micromamba env create \
      #     -n my-environment \
      #     anaconda::cudatoolkit \
      #     anaconda::cudnn \
      #     "anaconda::pytorch=*=*cuda*"

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
              exec nu
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
              pwninit
              checksec

              # rev
              gdb
              gef # gef extensions
              # Borked (removed due to weird updates) pwndbg # gef extensions
              inputs'.pwndbg.packages.default

              radare2

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
              brave

              mitmproxy
              sqlmap

              # for compatibility
              udev
              alsa-lib

              ida-free

              # crypto
              # BROKEN: sage

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
