barrowed from [EmergentMind](https://github.com/EmergentMind/nix-config/blob/a7b108082ccc5fd82322649a0cc4c32f86a53b02/nixos-installer/flake.nix#L56C1-L62C106)

## Custom ISO

"just iso" 
    from nix-config directory to generate the iso standalone

"just iso-install <drive>" 
    from nix-config directory to generate and copy directly to USB drive

"nix build ./nixos-installer#nixosConfigurations.iso.config.system.build.isoImage" 
    from nix-config directory to generate the iso manually


Generated images will be output to the ~/nix-config/results directory unless drive is specified
