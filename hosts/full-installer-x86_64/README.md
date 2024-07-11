## create custom ISO

\# If we dont remove this folder, libvirtd VM doesnt run with the new iso...

rm -rf result

\# Generated images will be output to ./result

nix build ./nixos-installer#nixosConfigurations.{name of profile}.config.system.build.isoImage

\# move the image to a drive

sudo dd if=$(eza --sort changed result/iso/*.iso | tail -n1) of={name of drive} bs=4M status=progress oflag=sync

