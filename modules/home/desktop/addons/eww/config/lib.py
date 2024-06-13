import subprocess
import time


def run_command(command) -> str:
    return subprocess.check_output(
        command,
        shell=True,
    ).decode()


def send_widget(widget_data):
    folded = widget_data.replace("\n", " ")

    last = ""
    compacted = ""
    for char in folded:
        if char == last == " ":
            continue

        last = char
        compacted += char

    print(
        compacted,
        flush=True,
    )


def main_dec(delta=0.1):
    def wrapper(foo):
        def sub_wrapper():
            last = ""

            try:
                for data in foo():
                    if data != last:
                        send_widget(data)
                    last = data

                    time.sleep(delta)
            except Exception as e:
                send_widget(f"""
                    (label 
                        :text \"{__file__} {e!r}\"
                    )
                """)
                raise e

        return sub_wrapper

    return wrapper


def main():
    # check if there is a battery
    power_data = run_command("ls /sys/class/power_supply")
    batterys = []
    for thing in power_data.split():
        if thing.startswith("BAT"):
            batterys.append(thing)

    if not batterys:
        send_literal_widget("")
        # send_literal_widget("(label :text \"test\")")

        return

    if len(batterys) > 1:
        raise TypeError(f"multiple batterys found ({batterys})")

    battery = batterys[0]

    last = ""

    while True:
        status = run_command(
            f"cat /sys/class/power_supply/{battery}/status"
        )

        charge = int(
            run_command(
                f"cat /sys/class/power_supply/{battery}/capacity"
            )
        )

        if status.startswith("Charging"):
            icon = "󰂄"
        else:
            icon = "󰂎󰁺󰁻󰁼󰁽󰁾󰁿󰂀󰂁󰂂󰁹"[round(charge / 10)]

        cur = f"""
            (something 
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
        send_literal_widget("""
            (label
                :text \"battery.py failed\")
        """)
