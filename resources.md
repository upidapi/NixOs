This is just for my own sake, to easely find referances
its not actually markdown i just like the colors :)

    
# to open the sops file
cd /persist/nixos; su --preserve-environment -c "
env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sops secrets/infra.yaml"

# build image
```bash
sudo mount /dev/---disc-name--- /ventoy

# build image
sudo nix build .#images.minimal-installer-x86_64

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

downloadFile "https://channels.nixos.org/nixos-24.05/latest-nixos-gnome-x86_64-linux.iso"
downloadFile "https://channels.nixos.org/nixos-24.05/latest-nixos-plasma6-x86_64-linux.iso"
downloadFile "https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso"
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


systemctl --user status sops-nix.service
journalctl -xeu home-manager-upidapi.service


cd /persist/nixos


nix shell nixpkgs\#ssh-to-age -c ssh-to-age -i /home/upidapi/.ssh/id_ed25519 -private-key -o /home/upidapi/tmp
env SOPS_AGE_KEY_FILE=/home/upidapi/tmp sops secrets/users/upidapi.yaml


ssh-to-age -i /etc/ssh/ssh_host_ed25519_key -private-key -o /home/upidapi/tmp


su --preserve-environment
env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sops secrets/users/upidapi.yaml


