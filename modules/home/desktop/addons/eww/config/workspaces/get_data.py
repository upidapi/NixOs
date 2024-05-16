import json
import subprocess
import sys
import time


def get_info():
    active_workspace = json.loads(
        subprocess.check_output(["hyprctl", "monitors", "-j"])
    )[int(sys.argv[1])]["activeWorkspace"]["id"]


    json_data = json.loads(
        subprocess.check_output(["hyprctl", "workspaces", "-j"])
    )

    def get_state(i):
        if i not in worksapces:
            return "inactive"
        
        if i != active_workspace:
            return "active"

        return "focused"

    worksapces = [x["id"] for x in json_data]

    out = ""

    for i in range(1, 11):
        out += f"(workspace_icon :state \"{get_state(i)}\" :index {i}) "

    return f""" 
        (box	
            :class "works"	
            :orientation "h" 
            :spacing 10
            :space-evenly "false" 
            
            {out}
    )""".replace("\n", " ")


def main():
    last = None
    while True:
        cur = get_info()
        if last != cur:
            print(cur, flush=True)
            last = cur

        time.sleep(0.05)


if __name__ == "__main__":
    main()

