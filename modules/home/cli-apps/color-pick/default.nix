{
  config,
  lib,
  pkgs,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.cli-apps.color-pick;
in {
  options.modules.home.cli-apps.color-pick =
    mkEnableOpt "adds a utillity for quickly picking color";

  # squircle generated from (but modified)
  # https://interfacecraft.online/squircle-svg-generator/

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "color-pick" ''
        # Original SVG file
        original_svg="${./squircle.svg}"
        # Temporary file
        temp_svg=$(mktemp /tmp/modified_svg.XXXXXX.svg)

        # color=$1
        # color="#00ff00"
        color="$(hyprpicker)"

        if [ -z "$color" ]; then
          exit 1
        fi

        sed "s/#f0d906/$color/g" "$original_svg" > "$temp_svg"

        # echo "$temp_svg"
        # cat "$temp_svg"

        wl-copy "$color"

        # echo to std out
        echo "$color"

        # Notify the user with a message
        notify-send -i "$temp_svg" "Hyprpicker" "$color"

        rm "$temp_svg"
      '')
    ];
  };
}
