{
  # config,
  # inputs,
  # lib,
  self,
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
              pwndbg # gef extensions

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
