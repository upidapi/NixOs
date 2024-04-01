# installs nixos on one of my machines
# each profile is specifically made for only one machine
# basically a customised nixos-install for my configuration

# control flow

# select host: (leave blank for custom host)
#   *show a tree view of the hosts*

# enter secret key passphrase:
#   *text is hidden*
#   *will be used to generate the key that decrypts my secrets*


# make sure is root
if [ "$EUID" -ne 0 ]
  then echo "This requires root to be run"
  exit
fi

#
profile="default"

mkdir /mnt/persist
git clone https://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@github.com/upidapi/NixOs.git /mnt/persist/nixos
# cd /mnt/persist/nixos

nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko "/mnt/persist/nixos/hosts/$profile/disko.nix"

# sudo nixos-generate-config --no-filesystems --root /mnt

nixos-install --flake "/mnt/persist/nixos#$profile"
