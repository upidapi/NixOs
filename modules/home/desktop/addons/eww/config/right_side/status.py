import subprocess
import time


def run_command(command):
    return subprocess.check_output(
        command,
        shell=True
    )

def send_literal_widget(data):
    print(data.replace("\n", " "), flush=True)



def run_main_loop(func, delta=0.1):
    last = ""
    
    while True:
        cur = func()
        if cur != last:
            last = cur
            
            send_literal_widget(cur)

        time.sleep(delta)

def construct_icon(icon):
    return f"""
        (label 
            :text \"{icon}\" 
            :visible {"true" if icon == "" else "false"}
        )
    """

def main_loop():
    airplane_mode = "" if bool(run_command("")) else ""
    headphones_mode = "" if bool(run_command("")) else ""
    microphone_mode = "" if bool(run_command("")) else ""
    wifi_mode = "" if bool(run_command("")) else ""
    
    return f"""
        (data_container
            {construct_icon("airplande")}
            {construct_icon("headphones")}
            {construct_icon("microphone")}
            {construct_icon("wifi")}
        )
    """


if __name__ == "__main__":
    run_main_loop(main_loop)

