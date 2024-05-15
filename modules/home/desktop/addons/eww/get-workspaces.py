import json
import subprocess

monitor = 0

active_workspace = json.loads(
    subprocess.check_output("hyprctl monitors -j")
)[monitor]["activeWorkspace"]["id"]


json_data = json.loads(
    subprocess.check_output("hyprctl workspaces -j")
)

worksapces = [x["id"] for x in json_data]
out = {
    i: ((i == active_workspace) + (i in worksapces))
    for i in range(1, 11)
}

print(json.dumps(out))
