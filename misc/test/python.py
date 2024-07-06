print("asdasd")


color_ids = {
    "none": 0,
    "green": "0;32",
}

colors = {
    color: f"\033[{color_id}m"
    for color, color_id in color_ids.items()
    #
}

while True:
    print(input(f"{colors['green']}>? {colors['none']}"))


