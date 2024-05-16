{pkgs, ...}: {
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      (builtins.replaceStrings ["\n"] [";"] ''
        monitors=$(
          hyprctl monitors -j | \
          python3 -c "import sys, json; print(len(json.load(sys.stdin)))"
        )

        for monitor in $(seq $monitors); do
          eww open bar --arg "monitor=$monitor";
        done
      '')
    ];
  };
}
