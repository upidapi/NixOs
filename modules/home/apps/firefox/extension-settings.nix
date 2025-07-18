pkgs: lib: settings: profile-path: let
  # REF: https://github.com/simonwjackson/mountainous/blob/dabb8ceea7f6750b6c533e4c035a2e2531898a34/modules/home/firefox/extensions.nix#L14
  extensionSettingsJson = builtins.toJSON settings;

  # FILE="$HOME/.mozilla/firefox/${config.mountainous.user.name}/extension-settings.json"
  # comes from the guy i took this from:

  # NOTE: an empty list doesn't override a list
  updateScript = pkgs.writeScript "update-firefox-extension-settings" ''
    #!${pkgs.stdenv.shell}
    set -euo pipefail

    FILE="$HOME/${profile-path}/extension-settings.json"
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
  config = {
    home.activation.updateFirefoxExtensionSettings =
      lib.hm.dag.entryAfter
      ["writeBoundary"] ''
        $DRY_RUN_CMD ${updateScript}
      '';
  };
}
