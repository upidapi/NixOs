monitors=$(
    hyprctl monitors -j | \
    python3 -c "import sys, json; print(len(json.load(sys.stdin)) - 1)"
)

for monitor in $(seq 0 "$monitors"); do
    eww open bar --arg "monitor=$monitor" --id "$monitor";
done
