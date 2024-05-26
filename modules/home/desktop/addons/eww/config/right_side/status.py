import subprocess
import time


def run_command(command):
    return subprocess.check_output(
        command,
        shell=True
    ).decode()

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


def check_network_connection():
    return run_command("""
        if (
            ping -c 1 archlinux.org || \
            ping -c 1 google.com || \
            ping -c 1 bitbucket.org || \
            ping -c 1 github.com || \
            ping -c 1 sourceforge.net
        ) &>/dev/null; then
            echo "1"
        else
            echo "0"
        fi
    """).startswith("1")


def get_active_connection():
    raw_data = run_command("""
        nmcli -m multiline connection show --active
    """)
    
    start_token = None
    connections = []
    buffer = []
    for line in raw_data.split("\n"):
        if line == "":
            continue

        key, val = line.split(":", 1)
        val = val.strip()

        if start_token == key:
           connections.append(buffer)
           buffer = []
        
        buffer.append((key, val))

        if start_token is None:
            start_token = key
    connections.append(buffer)
        
    parsed = [{
            key: val for key, val in connection
        } for connection in connections
    ]
    
    if not parsed:
        return False
    
    return parsed[0]["TYPE"]

def get_wifi_icon():
    active_connection = get_active_connection()
    
    """
    󰖩
    󱚵
    󰖪
    
    """
    if not active_connection:
        return ""
    
    is_working = check_network_connection()
    
    if not is_working:
        return "󱚵"
     
    return {
        "wifi": "󰖩",
        "ethernet": "",
        "lo": "",
    }[active_connection]


def get_parsed_bth_ctl():
    try:
        raw_data = run_command("bluetoothctl info")
    except subprocess.CalledProcessError:
        return []  # no connected bth devices
    
    raw_data = raw_data.splitlines()

    devices = []
    i = 0
    start = -1
    while i < len(raw_data):
        cur = raw_data[i]
        if cur.startswith("Device "):
            if start != -1:
                devices.append(raw_data[start:i])
                
            start = i
        i += 1
    devices.append(raw_data[start:])
    
    parsed = []
    for device in devices:
        parsed_device = {
            "name": device[0]
        }

        for thing in device[1:]:
            name, data = thing.split(": ", 1)
            name = name[1:]

            if name not in parsed_device.keys():
                parsed_device[name] = data
            else:
                if isinstance(parsed_device[name], list):
                    parsed_device[name].append(data)
                else:
                    parsed_device[name] = [parsed_device[name], data]
        
        parsed.append(parsed_device)
    
    return parsed


def bth_headphones_connected():
    parsed = get_parsed_bth_ctl()
    
    for connection in parsed:
        if connection["Icon"] == "audio-headset":
            return "󰋋"
        
    return ""


def construct_container(*icons):
    icons = [icon for icon in icons if icon]

    if not icons:
        return ""
    
    inside = ""
    for icon in icons:
        inside += f"""
            (label 
                :text \"{icon}\"
                :css \"* {{color: #000000}}\" 
            )
        """

    return f"""
        (data_container 
            {inside}
        )
    """




def get_mic_status():
    default_source = None
    # default_sink = None
    for line in run_command("pactl info").split("\n"):
        # if line.startswith("Default Sink: "):
        #     default_sink = line[len("Default Sink: "):]

        if line.startswith("Default Source: "):
            default_source = line[len("Default Source: "):]
    
    if default_source is None:
        return ""
    
    if run_command("pamixer --default-source --get-mute") == "true":
        return ""
    
    return ""
    # pamixer --source $_MIC --get-mute | awk '{print}'

def main_loop():
    # when XF86RFKill is toggled this is on
    # airplane_mode = "" if bool(run_command("")) else ""
    # TODO: airpalne mode

    # return "(label :text \"asd\")"

    return construct_container(
            bth_headphones_connected(),
            get_mic_status(),
            get_wifi_icon(),
        )


if __name__ == "__main__":
    try:
        run_main_loop(main_loop)
    except Exception as e:
        send_literal_widget("""
            (label 
                :text \"status.py failed\"
            )
        """)
