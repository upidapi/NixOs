# Description

Welcome to my overengineerd configuration for my computer systems. A concoction
of my better hallucinations (to clarify it's my own hallucinations), very
carefully bashed together to (hopefully) do something that is partially useful.
I've made this public primarily so that it can be used as a referance. Credits
are always nice, but not at all a requirement I've based large parts of it on
the work of others (see the Inspiration section bellow) So it feels like the
only right thing to do. (and also so that I can install it faster on my friends
computers when they happen to looking the other way)

<!----------------------this comment is 80 characters wide--------------------->

> [!CAUTION]
> This config is not a finished product, and will change as a continue to learn
> about nix. Things will be modified, updated, added, removed and restructured
> without warning.
>
> I'm not gonna tell you not to just run it, but I'll warn you that there's a
> good chance that it will break. This config is made for my machines, that have
> their own quirks. So make sure you backup your data before trying.

<!----------------------this comment is 80 characters wide--------------------->

If there's anything you take from this, (either figuratively or literally) I'm
particularly proud of my homelab setup and especially the media server part
[modules/nixos/homelab](/modules/nixos/homelab). it is fully declarative. In
theory, this means you should be able to just copy the configuration and end up
with the exact same setup on your machine. This is mostly made possible by
[declarr](https://github.com/updapi/declarr), a little side project of mine. It
acts as a lightweight syncing engine, for managing the *arr suite, sonarr,
radarr, (lidarr), seerr. Technically also jellyfin but that is only to fill in
the cracks of
[declarative-jellyfin](https://github.com/Sveske-Juice/declarative-jellyfin) a
truly amazing project, but its limited in its approach. (Ik about jellarr, but
it's also limited in its approach)

![document](https://github.com/upidapi/NixOs/blob/main/misc/images/desktop-minimal.png?raw=true)

## Features

A list of some of the more notable features

- homelab, fully declarative
  - media server + full *arr suite
  - configured using [declarr](https://github.com/upidapi/declarr), a
    (relatively) simple syncing script.
- [home-manager](https://github.com/nix-community/home-manager),
  used to configure users
- [impermanence](https://github.com/nix-community/impermanence),
  everything is wiped in reboot, only /persist actually persists
- modular, each thing is it's own module that you can enable
  - nixos modules are in modules/nixos
  - home-manager modules are in modules/home
- [disko](https://github.com/nix-community/disko), for declarative disks
- file hierarchy based hosts and users
  - logic in hosts/default.nix
  - machines defined in hosts/${host name}
  - users defined in hosts/\${host name}/users/\${user name}
- [ags](https://github.com/Aylur/ags), to create my top bar
- [stylix](https://github.com/danth/stylix), for system styling
  - although I'm moving away from this, I've noticed that I like the defaults
- custom neovim config using [mnw](https://github.com/Gerg-L/mnw),
  a simple wrapper around neovim
- [nix-portable](https://github.com/DavHau/nix-portable),
  for when you don't have nix nor root
  - probably doesn't work atm, been some time since i used it
- [sops-nix](https://github.com/Mic92/sops-nix), used for declarative secrets
  - stored (encrypted) in /secrets

## Install

<!-- ```bash
# Yeah dont use this, its you should use some other installer

# This installs my config on any computer that has nix

# Warning this will format your system with disko
# see /parts/install for more info
nix --extra-experimental-features "flakes " run github:upidapi/nixos#install
``` -->

## Create install iso

```bash
# see /parts/isos for more info
cd $NIXOS_CONFIG_PATH # where this repo is located

# build image
sudo nix build .#images.minimal-installer

# move to usb formatted with ventoy
sudo mkdir /ventoy

usb_drive=/dev/sdb1
sudo mount $usb_drive /ventoy

# move iso to usb
cp -rl $(eza --sort changed result/iso/*.iso | tail -n1) /ventoy
```

## Inspiration

Some of the people that I've ~stolen from~ been inspired by. There's probably
a lot more but I tend to forget to add them. Check out all "REF" and "FROM"
tags throughout the code along with
[trusted_repos.py](misc/scripts/trusted_repos.py) and my github stars for repos
i typically check for examples in.

- [jakehamilton](https://github.com/jakehamilton/config) -
  config structure, modules, suites, etc
- [notashelf](https://github.com/notashelf/nyx) -
  config file structure, random things
- [lokegustafsson](https://github.com/lokegustafsson/nixos-getting-started) -
  nix config, especially the global pining of nixpkgs
- [vimjoyer](https://www.youtube.com/@vimjoyer) -
  easy to follow guides for everything nix
- [NoBoilerplate](https://www.youtube.com/@NoBoilerplate) -
  made me start my stockholm syndrome filled journey with nixos
- [NobbZ](https://github.com/NobbZ/nixos-config/) - nix sops
- [SebastianStork](https://github.com/SebastianStork/nixos-config) - nix sops
- [EmergentMind](https://github.com/EmergentMind/nix-config) -
  yubikeys, remote bootstrapping
- [mic92](https://github.com/mic92/dotfiles) - dev shell

[fufexan](https://github.com/fufexan/dotfiles) -
[mitchellh](https://github.com/mitchellh/nixos-config) -
[workflow](https://github.com/workflow/dotfiles) -
[notohh](https://github.com/notohh/snowflake) -
[hlissner](https://github.com/hlissner/dotfiles) -
[gvolpe](https://ithub.com/gvolpe/nix-config)
