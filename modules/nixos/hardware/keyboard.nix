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

          # make alt+ctrl type the keys that altgr would
          control = {
            alt = "layer(altgr)";
          };

          alt = {
            control = "layer(altgr)";
          };
        };
      };
    };
  };
}
