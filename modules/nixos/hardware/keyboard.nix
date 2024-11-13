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
    # Configure keymap
    # "xserver" is actually just the general display server
    # so this actually configs wayland too.
    services.xserver.xkb = {
      layout = "se";
      variant = "";
    };

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
        };
      };
    };
  };
}
