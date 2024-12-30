## Description

Welcome to my overengineerd configuration for my computer systems. A concoction
of my better hallucinations, very carefully bashed together to (hopefully) do
something that is partially useful. I've made this public primarily so that it
can be used as a referance. Credits are always nice, but not at all a requirement
I've based large parts of it on the work of others (see the Inspiration section
bellow) So it feels like the only right thing to do. (and also so that I can
install it faster on my friends computers when they are looking the other way)

<!----------------------this comment is 80 characters wide--------------------->

> [!CAUTION]
> This config is not a finished product, and will change as a continue to learn
> about nix. Things will be modified, updated, added, removed and restructured
> without warning.
>
> I commit each time I (successfully) rebuild. So a large amount of commits are
> incomplete and or broken. And as in any other code, there is definetly a ton
> of mistakes sprinkled throughout the code :(.
>
> I'm not gonna tell you not to just run it, but I'll warn you that there's a
> good chance that it will break. This config is made for my machines, that have
> their own quirks. So make sure you backup your data before trying.
>
> You should probably avoid taking major parts of the code since it kinda
> cripples your ability to make quick changes to it. And if you do, make
> sure that you have some sort of overarching understanding of what it does.

<!----------------------this comment is 80 characters wide--------------------->

If there's anything you take out of this, (both figuratively and literally)
Id recommend you to take a look at the quick-switch script (in /parts/pkgs/qs).
Its a rebuild helper that commits each time you rebuild, while adding some
useful metadata to each commit, like generation and kernel version, along with
other things you probably want to do when rebuilding and working on your config.
It might sound a bit to verbose but its really nice to have when you eventually
mess something up.

![desktop](https://github.com/upidapi/NixOs/blob/main/misc/images/desktop-minimal.png?raw=true)

## Features

A list of some of the more notable features

- [home-manager](https://github.com/nix-community/home-manager),
  used to configure users
- [impermanence](https://github.com/nix-community/impermanence),
  everything is wiped in reboot, only /persist actually persists
- modular, each thing is it's own module that you can enable
  - nixos modules are in modules/nixos
  - home-manager modules are in modules/home
- [quick-switch](https://github.com/upidapi/NixOs/tree/main/parts/pkgs/qs),
  a rebuild and config helper
- [disko](https://github.com/nix-community/disko), for declarative disks
- file hierarchy based hosts and users
  - logic in hosts/default.nix
  - machines defined in hosts/${host name}
  - users defined in hosts/\${host name}/users/\${user name}
- [ags](https://github.com/Aylur/ags), to create my top bar
- [stylix](https://github.com/danth/stylix), for system styling
- custom neovim config using [mnw](https://github.com/Gerg-L/mnw),
  a simple wrapper around neovim
- [nix-portable](https://github.com/DavHau/nix-portable),
  for when you don't have nix nor root (probably doesn't atm)
- [sops-nix](https://github.com/Mic92/sops-nix), used for declarative secrets
  - stored (encrypted) in /secrets

## Install

```bash
# This installs my config on any computer that has nix

# Warning this will format your system with disko
# see /parts/install for more info
nix --extra-experimental-features "flakes " run github:upidapi/nixos#install
```

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

Some of the people that I've ~stolen from~ been inspired by. There's a lot more
but i tend to forget to add them. Check the bottom of the resources.md file for
repos i typically to check for examples in.

- [jakehamilton](https://github.com/jakehamilton/config) -
  Config structure, modules, suites, etc
- [notashelf](https://github.com/notashelf/nyx) -
  Config file structure, random things
- [lokegustafsson](https://github.com/lokegustafsson/nixos-getting-started) -
  nix config, especially the global pining of nixpkgs
- [ErrorNoInternet](https://github.com/ErrorNoInternet/configuration.nix) -
  nixvim config used as a reference
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
[gvolpe](https://github.com/gvolpe/nix-config)
