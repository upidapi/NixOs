# this script (should) fully install my nixos config
# requiring only a nixos install (eg the installer iso)


# make sure is root
if [ "$EUID" -ne 0 ]
  then echo "This requires root to be run"
  exit
fi

# we can't put this directly into /mnt/persist/nixos 
# since /mnt gets wiped when reformatting the disk with disko
git clone https://github.com/upidapi/NixOs /tmp/nixos


# make user select :a (valid) profile
raw_profile=$1

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

# check if user has provided valid profile to script
for host in "${hosts[@]}"; do
  if [[ $raw_profile == "$host" ]];
    then profile="load $raw_profile";
  fi
done


if [[ ! $# -eq 0 && $profile == "" ]]; then 
  echo "invallid profile";
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


# The persist modules can't persist files in a 
# folder that doesn't exist, and /persist/system is where 
# we store the system files. (the nixos installer doesn't 
# work otherwise)
# Therefour we have to manually create this folder
# (this took me about 2 full days to figure out, :) )
mkdir /mnt/persist/system


nixos-install --root /mnt --no-root-passwd --flake "/mnt/persist/nixos#$profile"

