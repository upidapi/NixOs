{
  config,
  my_lib,
  lib,
  pkgs,
  inputs,
  self',
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.home.other;
in {
  options.modules.home.other =
    mkEnableOpt "enables config that i've not found a place for";

  # A place to put random packages, should not contain config.
  # If it is configured it should instead be placed in ./misc
  config = mkIf cfg.enable {
    programs = {
      # view resources
      btop = enable;
      htop = enable;

      # ofc
      fastfetch = enable;

      # grep but better and faster
      ripgrep = enable;
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
                pyyaml

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

        # short tldr for manpages with examples
        tldr

        # minimal image viewer
        gwenview

        # terminal audio player
        mpv

        # video (/image/audio) viewer
        vlc

        # view/edit images
        gimp

        # flash card program
        anki

        # json parsing cmd
        jq

        wget

        unzip

        # show file struct
        tree

        # check network speed
        speedtest-cli

        # you can't have both?
        # clang
        gcc

        cargo
        rustc

        # for formatting a multiple iso usb
        ventoy

        # find out what process is using a file
        lsof

        # stats about code, logical lines, comments, etc
        scc
      ]);
  };
}
