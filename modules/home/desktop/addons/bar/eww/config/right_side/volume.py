import subprocess
import time


def run_command(
    command,
):
    return subprocess.check_output(
        command,
        shell=True,
    ).decode()


def send_literal_widget(
    data,
):
    print(
        data.replace(
            "\n",
            " ",
        ),
        flush=True,
    )


def run_main_loop(
    func,
    delta=0.1,
):
    last = ""

    while True:
        cur = func()
        if cur != last:
            last = cur

            send_literal_widget(cur)

        time.sleep(delta)


def main_loop():
    try:
        volume = int(run_command("pamixer --get-volume"))
        status = run_command("pamixer --get-volume-human")
    except subprocess.CalledProcessError:
        return ""

    icon = "󰕿󰖀󰕾"[round(volume / 100 * 2)]

    if status.startswith("muted"):
        icon = "󰖁"

    return f"""
        (something 
            :icon \"{icon}\"
            :text \"{volume}%\" 
        )
    """


if __name__ == "__main__":
    try:
        run_main_loop(main_loop)
    except Exception as e:
        send_literal_widget(f"""
            (label 
                :text \"{e!s}\"
            )
        """)
