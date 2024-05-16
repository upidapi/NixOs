import json
import subprocess
import time

"""
levels:

inactive
    nothing on it
active
    something on it
focused
    on one of the monitors
current
    on the current monitor
"""

def get_info():
    monitors = json.loads(
        subprocess.check_output(["hyprctl", "monitors", "-j"])
    )
    
    focused_workspaces = [monitor["activeWorkspace"]["id"] for monitor in monitors]

    out_data = []
    for monitor in monitors:
        current_workspace = monitor["activeWorkspace"]["id"]

        json_data = json.loads(
            subprocess.check_output(["hyprctl", "workspaces", "-j"])
        )

        workspaces = [x["id"] for x in json_data]

        def get_state(i):
            if i not in workspaces:
                return "inactive"
            
            if i not in focused_workspaces:
                return "active"

            if i != current_workspace:
                return "focused"

            return "current"

        out = ""

        for i in range(1, 11):
            out += f"(workspace_icon :state \"{get_state(i)}\" :index {i}) "

        out_data.append(f""" 
            (box	
                :class "works"	
                :orientation "h" 
                :spacing 10
                :space-evenly "false" 
                
                {out}
            )""".replace("\n", " "))

    return out_data


def main():
    last = None
    while True:
        cur = get_info()
        if last != cur:
            print(json.dumps(cur), flush=True)
            last = cur

        time.sleep(0.05)


if __name__ == "__main__":
    main()

