{
  config,
  mlib,
  lib,
  pkgs,
  inputs,
  self',
  ...
}: let
  inherit (mlib) mkEnableOpt enable;
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
      htop = enable;

      # ofc
      fastfetch = enable;

      # grep but better and faster
      ripgrep = enable;
    };

    home = {
      sessionVariables = {
        PAGER = "less";
        MANPAGER = "less";

        TERMINAL = "kitty"; # alacritty
        BROWSER = "zen"; # firefox
        EDITOR = "nvim";
      };

      file.".config/nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
        }
      '';

      packages =
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
          # tui for recursive directive sizes
          gdu

          # control audio nodes
          helvum

          # control audio
          pavucontrol

          # minecraft launcher
          prismlauncher

          # search nixpkgs with the terminal
          nix-search-cli

          # faster cpz and rmz
          fuc

          # find but better
          fd

          # short tldr for manpages with examples
          tldr

          # minimal image viewer
          kdePackages.gwenview

          # terminal audio player
          mpv

          # video (/image/audio) viewer
          vlc

          # view/edit images
          # https://github.com/NixOS/nixpkgs/pull/425710
          # BROKEN gimp

          # flash card program
          # anki

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
  };
}
