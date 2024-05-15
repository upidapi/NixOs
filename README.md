feel free to fork this if you want to use it as your own config

# description
My nixos configuration. Here's my main desktop: 
todo: add img of desktop


# features
* home-manager
* impermanence, root is wiped in reboot, only /persist presists
* modular, each thing is i'ts own module that you can enable
* * nixos modules are in modules/nixos
* * home-manager modules are in modules/nixos
* disko, for declarative disks
* file hirarcy based hosts and users
* * logic in hosts/default.nix
* * machines defined in hosts/${host name}
* * users defined in hosts/\${host name}/users/\${user name}

# install
    sudo nix-shell -p git --command "nix run --experimental-features 'nix-command flakes' https://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@github.com/upidapi/NixOs.git"


    sudo nix-shell -p git --command "git clone https://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@github.com/upidapi/NixOs.git /tmp/nixos; sudo bash /tmp/nixos/install.sh"

    (doesn't work, clone repo to /tmp/nixos, then run install.sh)

# inspiration
I've mainly taken inspiration and "borrowed" code from 

* https://github.com/Goxore/nixconf
* https://github.com/librephoenix/nixos-config
* https://github.com/jakehamilton/config
* https://github.com/ErrorNoInternet/configuration.nix
* https://github.com/fufexan/dotfiles
* https://github.com/Mic92/dotfiles
* https://github.com/workflow/dotfile
* https://github.com/notohh/snowflake?tab=readme-ov-file
* https://codeberg.org/adamcstephens/dotfiles

# Todos
* add nix sops
* base16.nix and stylix
* add a patches folder
* add a custom install iso?
* automated deployments? hydra?
* add licence
* nixd (language server)
