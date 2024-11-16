its not actually markdown i just like the colors :)

# open the (infra) sops file

```bash
sudo --preserve-env sops $NIXOS_CONFIG_PATH/secrets/

# not in direnv
env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sudo --preserve-env sops $NIXOS_CONFIG_PATH/secrets/

# without sudo
su --preserve-environment -c "env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt
sops $NIXOS_CONFIG_PATH/secrets/infra.yaml"
```

# run something without internet

```bash
# (doesn't work)
firejail --net=none
```

# build image

```bash
cd $NIXOS_CONFIG_PATH

sudo mkdir /ventoy

# eg /dev/sdb1
sudo mount /dev/---disc-name--- /ventoy

# build image
sudo nix build .#images.minimal-installer

# move iso to usb
cp -rl $(eza --sort changed result/iso/*.iso | tail -n1) /ventoy
```

# mount full disk

```bash
mkdir /btrfs_tmp; mount /dev/root_vg/root /btrfs_tmp
```

# resan and connect to phone

```bash
unpage nmcli device wifi list --rescan yes; nmcli device wifi connect upi-phone
```

# fetch official iso(s)

```bash
function downloadfile {
    # resolve url redirect to get a more specific link
    local url=$(curl -ils -o /dev/null -w %{url_effective} "$1")

    # curl said url and use the filename of it
    curl -jol "$url"
}

iso_names=(
    minimal
    gnome
    plasma6
)

for name in $iso_names; do
    echo "$name"
    downloadfile \
    "https://channels.nixos.org/nixos-24.05/latest-nixos-$1-x86_64-linux.iso"
done
```

# get logs

```bash
systemctl --user status
journalctl -xeu home-manager-upidapi.service
```

# format traces

```
# replace the folowing with something else
<code>
<primop>
<primop-app>
<lambda>
«repeated»
```

# get logs

```bash
systemctl --user status
journalctl -xeu home-manager-upidapi.service
```

# use to search some repos i trust for examples

```py
repos = """\
https://github.com/nobbz/nixos-config
https://github.com/fufexan/dotfiles
https://github.com/mitchellh/nixos-config
https://github.com/mic92/dotfiles
https://github.com/workflow/dotfiles
https://github.com/notohh/snowflake
https://github.com/misterio77/nix-config

https://github.com/hlissner/dotfiles

https://github.com/gvolpe/nix-config

https://github.com/notashelf/nyx\
"""

parsed = [
    x.strip()
    for x in repos.split("\n")
    if x.strip() != ""
]

data = [{
        "url": data,
        "host": data.split("/")[2],
        "user": data.split("/")[3],
        "name": data.split("/")[4],
    } for data in parsed
]

def get_github_seartch():
    repos = " OR ".join([f"repo:{d['user']}/{d['name']}" for d in data])

    print(f"lang:nix ({repos})")

def gen_md_credits():
    print(
        " - ".join([f"[{d['user']}]({d['url']})" for d in data])
    )

gen_md_credits()


# lang:nix (repo:nobbz/nixos-config OR repo:fufexan/dotfiles OR repo:mitchellh/nixos-config OR repo:mic92/dotfiles OR repo:workflow/dotfiles OR repo:notohh/snowflake OR repo:misterio77/nix-config OR repo:hlissner/dotfiles OR repo:gvolpe/nix-config OR repo:notashelf/nyx)
```
