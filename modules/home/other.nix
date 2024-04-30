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

    home.packages = with pkgs; [
      # used to formatt nix code
      inputs.alejandra.defaultPackage.${pkgs.system}

      unzip

      # show file struct
      tree

      # ofc
      neofetch

      # coding
      python3

      # you cant have both?
      clang
      # gcc

      cargo
      rustc

      # forensics
      imhex # hex edior
      audacity # audio foresics (and editor)
      sqlmap # sql injection
      # binary ninja
      ghidra

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
    ];
  };
}
