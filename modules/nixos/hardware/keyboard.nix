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
