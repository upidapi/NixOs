its not actually markdown i just like the colors :)

# open the (infra) sops file
```bash
sudo --preserve-env sops $NIXOS_CONFIG_PATH/secrets/

# not in direnv
env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sudo --preserve-env sops $$NIXOS_CONFIG_PATH/secrets/

# without sudo
su --preserve-environment -c "env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt 
sops $NIXOS_CONFIG_PATH/secrets/infra.yaml"
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


# fetch official iso(s)
```bash 
function downloadfile {
    # resolve url redirect to get a more specific link
    local url=$(curl -ils -o /dev/null -w %{url_effective} "$1")
    
    # curl said url and use the filename of it
    curl -jol "$url"
}

function downloadofficialiso {
    downloadfile \ 
    "https://channels.nixos.org/nixos-24.05/latest-nixos-$1-x86_64-linux.iso"
}

downloadofficialiso minimal 
downloadofficialiso gnome 
downloadofficialiso plasma6 
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

# get logs
```bash
systemctl --user status 
journalctl -xeu home-manager-upidapi.service
```

# get logs
```bash
systemctl --user status 
journalctl -xeu home-manager-upidapi.service
```

# get logs
```bash
systemctl --user status 
journalctl -xeu home-manager-upidapi.service
```

# get logs
```bash
systemctl --user status 
journalctl -xeu home-manager-upidapi.service
```


youtube
[vimjoyer](https://www.youtube.com/@vimjoyer) 


imp := impermanence
big := is there a lot?
h-m := home manager
flk := flakes?
flp := flake parts?
sps := sops


 [adv] [imp] [h-m] [flk] [sps]
[jakehamilton](https://github.com/jakehamilton/config) - modules
  [ ]   [ ]   [ ]   [x]   [ ]
[lokegustafsson](https://github.com/lokegustafsson/nixos-getting-started) - nix opts 
  [ ]   [ ]   [ ]   [ ]   [ ]
[errornointernet](https://github.com/errornointernet/configuration.nix) - nixvim
  [ ]   [ ]   [x]   [x]   [ ]
[nobbz](https://github.com/nobbz/nixos-config/)
  [x]   [ ]   [x]   [x]   [-]
[sebastianstork](https://github.com/sebastianstork/nixos-config)
  [ ]   [ ]   [x]   [x]   [x]
[fufexan](https://github.com/fufexan/dotfiles)
  [x]   [ ]   [x]   [x]   [-]
[mic92](https://github.com/mic92/dotfiles) - dev shell
  [x]   [ ]   [x]   [x]   [x]
[workflow](https://github.com/workflow/dotfiles)
  [ ]   [ ]   [x]   [x]   [ ]
[notohh](https://github.com/notohh/snowflake)
  [ ]   [ ]   [x]   [x]   [x]
[adamcstephens](https://codeberg.org/adamcstephens/dotfiles)
  [x]   [ ]   [x]   [x]   [ ]
[vimjoyer](https://github.com/vimjoyer/nixconf) - vimjoyer
  [ ]   [x]   [x]   [x]   [x]
[librephoenix](https://github.com/librephoenix/nixos-config) - sops, auto-install
  [x]   [ ]   [x]   [x]   [x]
[misterio77](https://github.com/misterio77/nix-config)
  [x]   [x]   [x]   [x]   [x]
[raf](https://github.com/notashelf/nyx) - well organised, huge
  [x]   [x]   [x]   [x]   [x]

[nvf](https://github.com/notashelf/nvf) - nixvim alternative
