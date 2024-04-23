import json
from os import path

data_path = path.join(path.dirname(__file__), "data.json")


with open(data_path) as f:
    data = json.load(f)


# enable = ["Disconnect"]

for addon in data["addons"]:
    # addon["active"] = addon["defaultLocale"]["name"] in enable

    addon["active"] = True

with open(data_path, "w") as f:
    json.dump(data, f, indent=2)

print("hello")
