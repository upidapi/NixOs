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


hosts=()
for dir in "${realpath $0}/./"


# make sure that user has selected a profile
# for example "deafult"
# if not promt them to choose one
if [ $# -eq 0 ]
  then echo "select priofile:";
  select a in */; do echo $a; done

  else profile=$1;
fi

echo "installing $profile"

#
profile="test"

git clone https://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@github.com/upidapi/NixOs.git /tmp/nixos
# cd /mnt/persist/nixos

nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko "/tmp/nixos/hosts/$profile/disko.nix"

mkdir /mnt/persist
mv /tmp/nixos /mnt/persist/nixos

# sudo nixos-generate-config --no-filesystems --root /mnt

mkdir /mnt/persist/system
nixos-install --root /mnt --flake "/mnt/persist/nixos#$profile"
