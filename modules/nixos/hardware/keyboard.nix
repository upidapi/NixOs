{
  lib,
  my_lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.nixos.hardware.keyboard;
in {
  options.modules.nixos.hardware.keyboard =
    mkEnableOpt "enables sound for the system";

  config = mkIf cfg.enable {
    services.xserver.exportConfiguration = true;

    # nix eval --expr "\"${(import <nixpkgs> {}).xkeyboard_config}/etc/X11/xkb\"" --impure

    # Configure keymap
    # "xserver" is actually just the general display server
    # so this actually configs wayland too. :)
    services.xserver.xkb = {
      layout = "gb,se";
      variant = "";
      options = "compose:menu, grp:alt_space_toggle";
    };

    # same for terminal
    console.useXkbConfig = true;

    # services.kanata = {
    #   enable = true;
    #   keyboards = {
    #     internalKeyboard = {
    #       # devices = [
    #       #   "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    #       # ];
    #       extraDefCfg = "process-unmapped-keys yes";
    #       config = ''
    #         (defsrc
    #          caps a s d f j k l ;
    #         )
    #         (defvar
    #          tap-time 150
    #          hold-time 200
    #         )
    #         (defalias
    #          caps (tap-hold 100 100 esc lctl)
    #          a (tap-hold $tap-time $hold-time a lmet)
    #          s (tap-hold $tap-time $hold-time s lalt)
    #          d (tap-hold $tap-time $hold-time d lsft)
    #          f (tap-hold $tap-time $hold-time f lctl)
    #          j (tap-hold $tap-time $hold-time j rctl)
    #          k (tap-hold $tap-time $hold-time k rsft)
    #          l (tap-hold $tap-time $hold-time l ralt)
    #          ; (tap-hold $tap-time $hold-time ; rmet)
    #         )
    #
    #         (deflayer base
    #          @caps @a  @s  @d  @f  @j  @k  @l  @;
    #         )
    #       '';
    #     };
    #   };
    # };
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = ["*"];

        /*
        [ids]
        *

        [main]
        capslock=overload(control, esc)


        [control]
        alt=layer(altgr)

        [alt]
        control=layer(altgr)
        */

        settings = {
          # https://github.com/NixOS/nixpkgs/issues/236622
          main = {
            # f caps lock
            # acts as esc on click, ctrl on hold
            capslock = "overload(control, esc)";
          };

          /*
          # im not actually using it
          # and it breaks stuff like switching tty

          # make alt+ctrl type the keys that altgr would
          control = {
            alt = "layer(altgr)";
          };

          alt = {
            control = "layer(altgr)";
          };
          */

          # FIXME: Compose doesn't work in older electron apps
          #  requires ~/.XCompose = ${pkgs.keyd}/share/keyd/keyd.compose
          #  however that is broken see
          #    https://github.com/electron/electron/issues/29345
          #  currently disabled

          altgr = {
            "a" = "å";
            "e" = "ä";
            "o" = "ö";
          };

          "shift+altgr" = {
            "a" = "Å";
            "e" = "Ä";
            "o" = "Ö";
          };
        };
      };
    };
  };
}
