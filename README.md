## description
This config is not a finished product, and will change as a continue to learn about nix. Things will be modified, updated, added, removed and restructured without warning. I commit each time I (successfully) rebuild so a large amount of commits are imcompleate and or partailly broken. So watch out for just blindly copying things whithout knowing what they do.

![my desktop](https://github.com/upidapi/NixOs/blob/main/images/desktop.png?raw=true)


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


## install
clone repo, then run install.sh


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

