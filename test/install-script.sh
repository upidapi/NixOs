sudo mkdir /mnt/persist
sudo git clone https://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@github.com/upidapi/NixOs.git /mnt/persist/nixos
sudo cd /mnt/persist/nixos

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./hosts/default/disko.nix
# sudo nixos-generate-config --no-filesystems --root /mnt

sudo nixos-install --flake /mnt/persist/NixOs#default
