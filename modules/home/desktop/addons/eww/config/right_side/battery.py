import subprocess
import time


def run_command(command) -> str:
    return subprocess.check_output(
        command,
        shell=True
    ).decode()

def send_literal_widget(data):
    print(data.replace("\n", " "), flush=True)



def main():
    # check if there is a battery
    power_data = run_command("ls /sys/class/power_supply")
    batterys = []
    for thing in power_data.split():
        if thing.startswith("BAT"):
            batterys.append(thing)

    if not batterys:
        send_literal_widget("""
            (something 
                :visible false
                :icon ""
                :text ""
            )
        """)
        
        return
    
    if len(batterys) > 1:
        send_literal_widget("""
            (label 
                :text "multiple batterys found"
            )
        """)
        
        return


    last = ""
    

    while True:
        status = run_command(
            "cat /sys/class/power_supply/BAT1/status"
        )
        
        charge = int(run_command(
            "cat /sys/class/power_supply/BAT1/capacity"
        ))
        
        if status == "Charging":
            icon = "󰂄"
        else:
            icon = "󰂎󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹"[round(charge / 10)]
        icon = "asd" 
            
        cur = f"""
            (something 
                :visible true
                :icon \"{icon}\"
                :text \"{charge}%\"
                {':color "#ff0000"' if charge <= 10 else ""}
            )
        """
        if cur != last:
            last = cur
            
            send_literal_widget(cur)

        time.sleep(0.1)


if __name__ == "__main__":
    try:
        main()    
    except Exception:
        send_literal_widget(f"""
            (label
                :text \"battery.py failed\")
        """)

