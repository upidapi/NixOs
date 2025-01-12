# various scripts for doing things

there's a few more at [/misc/resources](/misc/resources)

## open the (infra) sops file

```bash
# in direnv
sudo --preserve-env sops $NIXOS_CONFIG_PATH/secrets/

# not in direnv
env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt sudo --preserve-env sops $NIXOS_CONFIG_PATH/secrets/

# without sudo
su --preserve-environment -c "env SOPS_AGE_KEY_FILE=/persist/sops-nix-key.txt
sops $NIXOS_CONFIG_PATH/secrets/infra.yaml"
```

## build image

```bash
cd $NIXOS_CONFIG_PATH

sudo mkdir /ventoy

# eg /dev/sdb1
sudo mount /dev/---disc-name--- /ventoy

# build image
sudo nix build .#images.minimal-installer

# move iso to usb
cp -rl $(eza --sort changed result/iso/*.iso | tail -n1) /ventoy
```

## mount full disk

```bash
mkdir /btrfs_tmp; mount /dev/root_vg/root /btrfs_tmp
```

## resan and connect to phone

```bash
PAGER=cat nmcli device wifi list --rescan yes; nmcli device wifi connect upi-phone
```

## get logs

```bash
systemctl --user status
journalctl -xeu home-manager-upidapi.service
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

## mount lvm subvolumes

```bash
mount -o subvol=/root /dev/sda/root_vg/root /mnt
```

## install the nixos bootloader

```bash
mount -o subvol=/root /dev/sda/root_vg/root /mnt
mount -o subvol=/nix /dev/sda/root_vg/root /nix
mount -o subvol=/persist /dev/sda/root_vg/root /persist

mount /dev/sda2 /boot

nixos-enter
NIXOS_INSTALL_BOOTLOADER=1 \ 
    /nix/var/nix/profiles/system/bin/switch-to-configuration boo
```
