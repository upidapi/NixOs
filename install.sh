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


# make user select :a (vallid) profile
raw_profile=$1

config_dir=$(dirname /persist/nixos/install.sh)
raw_hosts=$(find "$config_dir/hosts" -maxdepth 1 -mindepth 1 -type d)

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

# clone my nixos git repo
git_pat="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"
git_url="https://$git_pat@github.com/upidapi/NixOs.git" 
git clone $git_url /tmp/nixos

# formatt with disko
nix \
  --experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko "/tmp/nixos/hosts/$profile/disko.nix"


mkdir /mnt/persist
mv /tmp/nixos /mnt/persist/nixos

# The persist modules can't perisist files in a 
# folder that doesn't exist, and /persist/system is where 
# we store the system files. (the nixos installer doesn't 
# work otherwise)
# Therefour we have to manualy create this folder
# (this took me about 2 full days to figure out, :) )
mkdir /mnt/persist/system

# sudo nixos-generate-config --no-filesystems --root /mnt

mkdir /mnt/persist/system
nixos-install \
  --root /mnt \
  --flake "/mnt/persist/nixos#$profile"
