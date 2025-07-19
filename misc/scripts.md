# various scripts for doing things

there's a few more at [/misc/resources](/misc/resources)

## build image
```bash
cd $NIXOS_CONFIG_PATH

sudo mkdir /ventoy

# eg /dev/sdb1
sudo mount /dev/sdX1 /ventoy -o sync

# build image
nix build .#images.minimal-ce

# move iso to usb
rsync -ah --progress result/iso/*.iso /ventoy
# cp -rl $(eza --sort changed result/iso/*.iso | tail -n1) /ventoy
```

## Fix corrupted / missing store paths
```bash
sudo nix-store --verify --check-contents --repair
```

## make temp swap file
```bash
truncate -s 0 /swap
chattr +C /swap
fallocate -l 64G /swap
chmod 0600 /swap
mkswap /swap
swapon /swap
```

## mount full disk
```bash
mkdir /btrfs_tmp; mount /dev/root_vg/root /btrfs_tmp
```

## install the nixos bootloader
```bash
mkdir /mnt/nix
mkdir /mnt/persist

mount -o subvol=/root /dev/root_vg/root /mnt
mount -o subvol=/nix /dev/root_vg/root /mnt/nix
mount -o subvol=/persist /dev/root_vg/root /mnt/persist

mount /dev/sda2 /mnt/boot

nixos-enter

NIXOS_INSTALL_BOOTLOADER=1 \
    /nix/var/nix/profiles/system/bin/switch-to-configuration boot
```

## mount lvm subvolumes
```bash
mount -o subvol=/root /dev/sda/root_vg/root /mnt
```

## open the (infra) sops file
```bash
# in direnv
sudo --preserve-env sops $NIXOS_CONFIG_PATH/secrets/infra.yaml
# or
sops-edit infra

# not in direnv
env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sudo --preserve-env sops $NIXOS_CONFIG_PATH/secrets/

# without sudo
su --preserve-environment -c "env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt
sops $NIXOS_CONFIG_PATH/secrets/infra.yaml"

env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sudo --preserve-env sops $"($env.NIXOS_CONFIG_PATH)/secrets/shared.yaml"
```

## resan and connect to phone
```bash
PAGER=cat nmcli device wifi list --rescan yes; nmcli device wifi connect upi-phone
```

## interactive file size search
```bash
cd /; sudo , gdu
```

## format traces
```txt
# replace the folowing with something else
<code>
<primop>
<primop-app>
<lambda>
«repeated»
```

## ocr image
```bash
, tesseract test.png stdout
```

## modify keyboard
```bash
# in cromium (since firefox doesn't support it)

# try to connect at
https://usevia.app/

# go to
brave://device-log/
# [23:34:15] Failed to open '/dev/hidraw4': FILE_ERROR_ACCESS_DENIED

chmod 766 /dev/hidraw4

# it should not work
```
