This is just for my own sake
its not actually markdown i just like the colors :)

# open the (infra) sops file
```bash
cd "$NIXOS_CONFIG_PATH"; su --preserve-environment -c "
env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sops secrets/infra.yaml"


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
cp -rL $(eza --sort changed result/iso/*.iso | tail -n1) /ventoy
```

# fetch official iso(s)
```bash 
function downloadFile {
    # resolve url redirect to get a more specific link
    local url=$(curl -ILs -o /dev/null -w %{url_effective} "$1")
    
    # curl said url and use the filename of it
    curl -JOL "$url"
}

function downloadOfficialIso {
    downloadFile \ 
    "https://channels.nixos.org/nixos-24.05/latest-nixos-$1-x86_64-linux.iso"
}

downloadOfficialIso minimal 
downloadOfficialIso gnome 
downloadOfficialIso plasma6 
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
H-M := home manager
flk := flakes?
flp := flake parts?
sps := sops


 [adv] [imp] [H-M] [flk] [sps]
[jakehamilton](https://github.com/jakehamilton/config) - modules
  [ ]   [ ]   [ ]   [x]   [ ]
[lokegustafsson](https://github.com/lokegustafsson/nixos-getting-started) - nix opts 
  [ ]   [ ]   [ ]   [ ]   [ ]
[ErrorNoInternet](https://github.com/ErrorNoInternet/configuration.nix) - nixvim
  [ ]   [ ]   [x]   [x]   [ ]
[NobbZ](https://github.com/NobbZ/nixos-config/)
  [x]   [ ]   [x]   [x]   [-]
[SebastianStork](https://github.com/SebastianStork/nixos-config)
  [ ]   [ ]   [x]   [x]   [x]
[fufexan](https://github.com/fufexan/dotfiles)
  [x]   [ ]   [x]   [x]   [-]
[mic92](https://github.com/Mic92/dotfiles) - dev shell
  [x]   [ ]   [x]   [x]   [x]
[Workflow](https://github.com/workflow/dotfiles)
  [ ]   [ ]   [x]   [x]   [ ]
[Notohh](https://github.com/notohh/snowflake)
  [ ]   [ ]   [x]   [x]   [x]
[Adamcstephens](https://codeberg.org/adamcstephens/dotfiles)
  [x]   [ ]   [x]   [x]   [ ]
[vimjoyer](https://github.com/vimjoyer/nixconf) - vimjoyer
  [ ]   [x]   [x]   [x]   [x]
[Librephoenix](https://github.com/librephoenix/nixos-config) - sops, auto-install
  [x]   [ ]   [x]   [x]   [x]
[Misterio77](https://github.com/Misterio77/nix-config)
  [x]   [x]   [x]   [x]   [x]
[raf](https://github.com/NotAShelf/nyx) - well organised, huge
  [x]   [x]   [x]   [x]   [x]

[nvf](https://github.com/NotAShelf/nvf) - nixvim alternative



