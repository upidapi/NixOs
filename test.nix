{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.cli-apps.clr-pckr;
in {
  options.modules.home.cli-apps.clr-pckr =
    mkEnableOpt
    "Whether or not to add the clr-pckr command";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "clr-pckr"
        /*
        bash
        */
        ''
          color=$(hyprpicker -n)

          if test -z "$color"; then
              echo "Program aborted by user. Exiting..."
              exit 1
          fi

          wl-copy "$color"
          echo "$color"

          # Generated with https://interfacecraft.online/squircle-svg-generator/
          # However it is far from perfect so I have also made som manual changes
          # using inkscape.
          squircle_black="${./squircle.svg}"
          squircle_color=$(mktemp --suffix=.svg)

          if test -z "$squircle_color"; then
              echo "Failed to generate tmp file. Exiting..."
              exit 1
          fi

          sed "s/#000000/$color/" "$squircle_black" > "$squircle_color"

          notify-send --icon "$squircle_color" "Hyprpicker" "$color"

          rm "$squircle_color"
        '')
    ];
  };
}
