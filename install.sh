# this script assumes that the repo is located at /tmp/nixos

# make sure is root
if [ "$EUID" -ne 0 ]
  then echo "This requires root to be run"
  exit
fi



# make user select :a (vallid) profile
raw_profile=$1

# config_dir=$(dirname /persist/nixos/install.sh)
raw_hosts=$(find "/tmp/nixos/hosts" \
    -maxdepth 1 \
    -mindepth 1 \
    -type d
)

hosts=()
for dir in $raw_hosts; do
  res=$(basename "$dir")
  hosts+=("$res")
done;

# check if user has provieded valid profile to script
for host in "${hosts[@]}"; do
  if [[ $raw_profile == "$host" ]];
    then profile=$raw_profile;
  fi
done

if [[ ! $# -eq 0 && $profile == "" ]]; then 
  echo "invallid priofile";
  echo "";
fi

# choose profile
if [[ $profile == "" ]]; then
  echo "select priofile:"
  select host in "${hosts[@]}"; do
    profile=$host;
    break;
  done;
fi



# formatt the file system with disko
nix \
  --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko "/tmp/nixos/hosts/$profile/disko.nix"



# move the config to the correct place, since disko would've 
# erased it (along with everything else in /persist)
mkdir /mnt/persist
cp -r /tmp/nixos /mnt/persist/nixos



# store the profile in a file to preserve it for the
# part after the reboot
echo "$profile" > /mnt/persist/nixos/profile-name.txt



# The persist modules can't perisist files in a 
# folder that doesn't exist, and /persist/system is where 
# we store the system files. (the nixos installer doesn't 
# work otherwise)
# Therefour we have to manualy create this folder
# (this took me about 2 full days to figure out, :) )
mkdir /mnt/persist/system



# now we have to create a conventional config to start,
# since nixos-insall cant handle flakes

# geneate a tmp hardware cfg that includes the files system
# since disko doesn't work whithout flakes
nixos-generate-config \
  --root /mnt \
  --show-hardware-config \
> "/mnt/etc/nixos/hardware.nix"

# just a quite barebones config to start with, soly
# used to bootstrap the real one
cp ./bootstrap-config.nix /mnt/etc/nixos/configuration.nix

nixos-install --root /mnt
