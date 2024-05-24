import subprocess
import time


def run_command(command):
    return subprocess.check_output(
        command,
        shell=True
    )

def send_literal_widget(data):
    print(data.replace("\n", " "), flush=True)



def main():
    # check if there is a battery
    if not run_command("ls /sys/class/power_supply"):
        send_literal_widget("""
            (something 
                :visible false
                :icon ""
                :text ""
            )
        """)
        
        return

    last = ""
    
    while True:
        status = "asd"
        # status = run_command(
        #     "cat /sys/class/power_supply/BAT1/status"
        # )
        
        charge = 10 
        
        # int(run_command(
        #     "cat /sys/class/power_supply/BAT1/capacity"
        # ))
        
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
    main()

