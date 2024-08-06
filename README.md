## description
Welcome to my overengineerd configuration for my computer systems. A concoction of my better hallucinations, not very carefully orchestrated to (hopefully) do something that is at least partially useful. I've made this public for it to be used as a reference (and so that i can install it faster on random systems)


This config is not a finished product, and will change as a continue to learn about nix. Things will be modified, updated, added, removed and restructured without warning. I commit each time I (successfully) rebuild so a large amount of commits are incomplete and or broken. So if you take someting make sure that you understand what it does. It is also made specifically for my machine with their own quirks. Dont expect it to work on yours. If you decide to (against my advice) try to boot this. Please make sure you have backups of your data. And a good backup plan in the case that you can't boot. 

![my desktop](https://github.com/upidapi/NixOs/blob/main/misc/images/desktop.png?raw=true)


## features
- home-manager, used to configure users 
- impermanence, (almost) everything is wiped in reboot, only /persist persists
- modular, each thing is it's own module that you can enable
  - nixos modules are in modules/nixos
  - home-manager modules are in modules/home
- disko, for declarative disks
- file hierarchy based hosts and users
  - logic in hosts/default.nix
  - machines defined in hosts/${host name}
  - users defined in hosts/\${host name}/users/\${user name}
- custom top bar made with ags

The structure of my config was inpired by raf and jakehamilton

## install
```bash 
# Warning this will format your system with disko 
nix run github:upidapi/nixos#install 
```


## create iso
to create the isos you have to run the folowing commands
    
    `
    
    `{:.bash}


## insperation
Some of the people that I've ~stolen from~ been insperd by. Theres probably a lot more but i tend to forget to add them. 

- [jakehamilton](https://github.com/jakehamilton/config) - config organised into modules and suites 
- [lokegustafsson](https://github.com/lokegustafsson/nixos-getting-started) - nix defaults, especially the global pining of nixpkgs
- [ErrorNoInternet](https://github.com/ErrorNoInternet/configuration.nix) - nixvim config used as a reference
- [vimjoyer](https://www.youtube.com/@vimjoyer) - easy to follow guides for everything nix
- [NoBoilerplate](https://www.youtube.com/@NoBoilerplate) - made me start my stockholm syndrome filled journey with nixos
- [NobbZ](https://github.com/NobbZ/nixos-config/) - nix sops
- [SebastianStork](https://github.com/SebastianStork/nixos-config) - nix sops
- [fufexan](https://github.com/fufexan/dotfiles)
- [mic92](https://github.com/Mic92/dotfiles)
- [Workflow](https://github.com/workflow/dotfiles)
- [Notohh](https://github.com/notohh/snowflake)
- [Adamcstephens](https://codeberg.org/adamcstephens/dotfiles)
- [goxore](https://github.com/Goxore/nixconf)
- [Librephoenix](https://github.com/librephoenix/nixos-config)

