feel free to fork this if you want to use it as your own config

# description
My nixos configuration. Here's my main desktop: 
todo: add img of desktop

It uses the following:

## flakes
I use flakes, along with flake-parts as a easy way to do pkg version locking

## home manager
Home manager is a tool for configuring user files.

In my case I use it as a nixos module. This is done to more tightly be able 
to integrate it into a part of my config.

Basically everything that 
can be configured with home-manager is configured with home manager.  

## sops nix
I use sops nix for secret management.

## impermanence
My configs are made to be fully stateless. You should be able to jump 
generations freely and know that if the config works once, then it works 
forever. 

To ensure this I simply wipe my computer on reboot, saving only /nix and /persist. 
Forcing a stateless configuration. Where no files on the computer affects how it 
works. Because if they did, then they'd get removed and the system would 
quickly break.

But don't worry about forgetting to put somthing in the right place. The files 
aren't truly removed but instead moved to /btrfs_tmp/old_roots/. Where they 
persist for 30 days before actually getting removed. 

Ofc some other files are preserved, like your tabs on firefox. This is achieved 
with the "persist" module. In this case it preserved ~/.mozilla/firefox 

## disko
Well the disk partitions is also a sort of state. So I use disko to define the 
partitions on my disks.  

## modular
The config is made to be modular, where each module should be configured at the 
option \*path to module\*. I.e a module at ./modules/abc/xyz.nix would check 
options.modules.abc.zyz for its personal config. 

Modules are also always imported (note that this isn't automatic), and should 
never set any config unless explicitly enabled (i.e .enable = true)


# install
first boot up some kind of nixos install (for example a nixos iso)

then run
    
    sudo nix-shell -p git --command "nix run --experimental-features 'nix-command flakes' https://github.com/upidapi/NixOs.git"



You will then be promoted for, first a machine configuration profile. I.e one 
of the subdirectories in ./hosts.

Then you'll be promoted for my™ private key passphrase. Which will then be used
to derive my private key that will be stored on your machine for encryption and 
decryption of my™ secrets stored in nix sops.

Unless you're me, or have somehow gotten access to my private key passphrase (if
so, please give it back). Then you'll want to edit the sops.yaml file with your 
logins. You only have to add those who you'll use. Simply ignore the rest. Then 
rebuild and everything *should* work.


# inspiration
I've mainly taken inspiration and "borrowed" code from 

* https://github.com/Goxore/nixconf
* https://github.com/librephoenix/nixos-config
* https://github.com/jakehamilton/config
* https://github.com/ErrorNoInternet/configuration.nix
* https://github.com/fufexan/dotfiles
* https://github.com/Mic92/dotfiles
* https://github.com/workflow/dotfiles

# Todos
* add nix sops
* base16.nix and stylix
* add a patches folder
* add a custom install iso?
* automated deployments? hydra?
* add licence
* nixd (language server)
