{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.modules.home.apps.firefox;

  # REF: https://github.com/simonwjackson/mountainous/blob/dabb8ceea7f6750b6c533e4c035a2e2531898a34/modules/home/firefox/extensions.nix#L14
  extensionSettingsJson = builtins.toJSON {
    commands = {
      styleDisableAll = {
        precedenceList = [
          {
            # set disable keybind for stylus
            id = "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}";
            value = {
              shortcut = "Alt+Shift+W";
            };
          }
        ];
      };
      # _execute_browser_action = {
      #   precedenceList = [
      #     {
      #       id = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      #       value = {
      #         shortcut = "Ctrl+Alt+P";
      #       };
      #       enabled = true;
      #     }
      #   ];
      # };
      # lock = {
      #   precedenceList = [
      #     {
      #       id = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      #       value = {
      #         shortcut = "";
      #       };
      #       enabled = true;
      #     }
      #   ];
      # };
      # toggle = {
      #   precedenceList = [
      #     {
      #       id = "addon@darkreader.org";
      #       value = {
      #         shortcut = "";
      #       };
      #       enabled = true;
      #     }
      #   ];
      # };
      # addSite = {
      #   precedenceList = [
      #     {
      #       id = "addon@darkreader.org";
      #       value = {
      #         shortcut = "Ctrl+Alt+D";
      #       };
      #       enabled = true;
      #     }
      #   ];
      # };
    };
  };

  # FILE="$HOME/.mozilla/firefox/${config.mountainous.user.name}/extension-settings.json"
  # comes from the guy i took this from:

  # TODO: genralise the config.home.username for the profile name
  #  currently this only works for that profile

  # BUG: If a precedenceList is empty, the object wont append
  updateScript = pkgs.writeScript "update-firefox-extension-settings" ''
    #!${pkgs.stdenv.shell}
    set -euo pipefail

    FILE="$HOME/.mozilla/firefox/${config.home.username}/extension-settings.json"
    TEMP_FILE=$(mktemp)

    # Ensure the directory exists
    mkdir -p "$(dirname "$FILE")"

    # If the file doesn't exist, create it with the full content
    if [ ! -f "$FILE" ]; then
      echo '${extensionSettingsJson}' > "$FILE"
      exit 0
    fi

    # Merge the existing content with our desired content
    ${pkgs.jq}/bin/jq -s '
      .[0] as $existing |
      .[1] as $new |
      $existing * $new
    ' "$FILE" <(echo '${extensionSettingsJson}') > "$TEMP_FILE"

    # Replace the original file with the merged content
    mv "$TEMP_FILE" "$FILE"
  '';
in {
  config = mkIf cfg.enable {
    home.activation.updateFirefoxExtensionSettings =
      lib.hm.dag.entryAfter
      ["writeBoundary"] ''
        $DRY_RUN_CMD ${updateScript}
      '';
  };
}
