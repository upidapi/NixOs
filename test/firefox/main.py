import json

with open("./data.json") as f:
    data = json.load(f)


# enable = ["Disconnect"]

for addon in data["addons"]:
    # addon["active"] = addon["defaultLocale"]["name"] in enable

    addon["active"] = True

with open("./data.json", "w") as f:
    json.dump(data, f, indent=2)
