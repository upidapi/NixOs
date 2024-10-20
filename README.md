## description
Welcome to my overengineerd configuration for my computer systems. A 
concoction of my better hallucinations, very carefully bashed together  
to (hopefully) do something that is partially useful. I've made this 
public for it to be used as a reference (and so that i can install it 
faster on my friends computers when they aren't looking)

If there's anything you take from this. Id recommend you to take a 
look at the quick-switch script (in /parts/pkgs/qs). Its a rebuild 
helper that forces you to commit for each change, while adding some 
metadata to each commit, along with other things you probably want 
to do when rebuilding and working on your config. It's really nice 
to have when you eventually really mess something up.

> [!CAUTION]
> This config is not a finished product, and will change as a continue 
> to learn about nix. Things will be modified, updated, added, removed 
> and restructured without warning. 
> 
> I commit each time I (successfully) rebuild. So a large amount of commits 
> are incomplete and or broken. And as in any other code, there is 
> definetly a ton of mistakes sprinkled throughout the code :(.
>
> I'm not gonna tell you not to try to boot it, but I'll warn you that 
> there's a good chance that it will break. This config is made for my 
> machines, that have their own quirks. So make sure you backup your 
> data before trying.


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

The structure of my config is heavily inspired by raf and jakehamilton

## install
```bash 
# Warning this will format your system with disko 
# and probably doesn't work
nix --extra-experimental-features "flakes " run github:upidapi/nixos#install 
```


## create iso
to create the isos you have to run the folowing commands
    
    `
    
    `{:.bash}


## insperation
Some of the people that I've ~stolen from~ been inspired by. There's probably 
a lot more but i tend to forget to add them. Check the bottom of the resources.md 
file for repos i like to check for examples in.

- [jakehamilton](https://github.com/jakehamilton/config) - Config structure, modules, suites, etc
- [lokegustafsson](https://github.com/lokegustafsson/nixos-getting-started) - nix config, especially the global pining of nixpkgs
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

