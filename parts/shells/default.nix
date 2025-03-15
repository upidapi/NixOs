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

    cuda-pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
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
          exec nu
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
            runScript = pkgs.writeShellScript "fhs-init" ''
              name="cmp-prog-fhs"
              exec nu
            '';
          })
        .env;

      # i recommend to add the nix-community cache, otherwise this will take
      # hours to build with cudaSupport
      ai = cuda-pkgs.mkShellNoCC {
        name = "ai";
        packages = with pkgs; [
          (python3.withPackages (ps:
            with ps; [
              # if you want to use pytorch-bin then you have to
              # make sure that torch-vision is using that too
              pytorch
              # torchvision
              # matplotlib
              # numpy
              # mlflow
            ]))
          # linuxPackages.nvidia_x11
          # libGLU
          # libGL
          # xorg.libXi
          # xorg.libXmu
          # freeglut
          # xorg.libXext
          # xorg.libX11
          # xorg.libXv
          # xorg.libXrandr
          # zlib
          # ncurses5
          # stdenv.cc
          # binutils
          # ffmpeg
        ];

        profile = ''
          export LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib"
          export CUDA_PATH="${pkgs.cudatoolkit}"
          export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
          export EXTRA_CCFLAGS="-I/usr/include"
        '';

        shellHook = ''
          exec nu
        '';
      };

      ai-fhs =
        (cuda-pkgs.buildFHSEnv {
          name = "ai-fhs";
          targetPkgs = _pkgs: (with _pkgs; [
            (_pkgs.python3.withPackages (ps:
              with ps; [
                pytorch
              ]))
          ]);

          profile = ''
            export LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib"
            export CUDA_PATH="${pkgs.cudatoolkit}"
            export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
            export EXTRA_CCFLAGS="-I/usr/include"
          '';

          runScript = pkgs.writeShellScript "fhs-init" ''
            name="ai-fhs"
            exec nu
          '';
        })
        .env;

      sec =
        # https://www.alexghr.me/blog/til-nix-flake-fhs/
        # https://ryantm.github.io/nixpkgs/builders/special/fhs-environments/
        # creates a fsh to run random (unpackaged) binarys
        # if i understand correctly its the same as buildFHSUserEnv
        (pkgs.buildFHSEnv
          {
            name = "cmp-prog-fhs";
            runScript = pkgs.writeShellScript "fhs-init" ''
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
              # if you want to use pytorch-bin then you have to
              # make sure that torch-vision is using that too
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
