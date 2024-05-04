{
  config,
  my_lib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.other;
in {
  options.modules.home.other =
    mkEnableOpt "enables config that i've not found a place for";

  # TODO: put thease things into it's own modules
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
      ]
      ++ (with pkgs; [
        unzip

        # show file struct
        tree

        # ofc
        neofetch

        # coding
        python3

        # you cant have both?
        clang
        # (lib.hiPrio gcc)

        cargo
        rustc

        # forensics
        imhex # hex edior
        audacity # audio foresics (and editor)
        sqlmap # sql injection
        # binary ninja
        ghidra
        radare2
        gimp

        gimp

        binwalk
        file
        ltrace
        strace

        # for formating a multiple iso usb
        ventoy

        # TODO:
        #  binwalk
        #  string

        # find out what proces is using a file
        lsof

        # other
        htop
        ripgrep

        # stats about code, logical lines, comments, etc
        scc

        # maybe btop
      ]);
  };
}