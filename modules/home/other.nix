{
  config,
  my_lib,
  lib,
  pkgs,
  inputs,
  self',
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.other;
in {
  options.modules.home.other =
    mkEnableOpt "enables config that i've not found a place for";

  # TODO: put thease things into their own modules
  config = mkIf cfg.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };

    home.packages =
      [
        # used to formatt nix code
        inputs.alejandra.defaultPackage.${pkgs.system}
        self'.packages.dev-shell
        self'.packages.qs
      ]
      ++ (with pkgs; [
        (
          python3.withPackages (
            python-pkgs:
              with python-pkgs; [
                pandas
                requests

                dbus-python
                pygobject3

                pillow
                # bleak  # bth le
                # pybluez
              ]
          )
        )

        unzip

        # show file struct
        tree

        # ofc
        fastfetch

        # check network speed
        speedtest-cli

        # you can't have both?
        clang
        # (lib.hiPrio gcc)

        cargo
        rustc

        # for formatting a multiple iso usb
        ventoy

        # find out what process is using a file
        lsof

        # other
        htop
        ripgrep

        # stats about code, logical lines, comments, etc
        scc

        # maybe btop

        vlc

        # forensics
        imhex # hex editor
        audacity # audio foresics (and editor)
        sqlmap # sql injection
        # TODO: binary ninja
        ghidra
        radare2
        gimp

        binwalk
        file
        ltrace
        strace
      ]);
  };
}
