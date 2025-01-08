{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.misc.impermanence;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.modules.nixos.os.misc.impermanence =
    mkEnableOpt "enables impermanence";

  config = mkIf cfg.enable {
    fileSystems."/persist".neededForBoot = true;

    # required by home manager impermanance
    programs.fuse.userAllowOther = true;

    # nukes root
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/root_vg/root /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';

    # we persist everything relative under /persist/system eg.
    # /etc/ssh => /persist/system/etc/ssh
    # /home/upidapi/.ssh => /persist/system/home/upidapi/.ssh

    # disko can't / won't automatically create the storage locations
    # so we have to create them ourselves (they might have chagned this)
    systemd.tmpfiles.rules =
      [
        # /persist/system created, owned by root
        "d /persist/system/ 0777 root root -"

        # /persist/system/home created, owned by root
        "d /persist/system/home/ 0777 root root -"

        # make sure that each user owns it's own persistent
        # home directory
      ]
      ++ (
        builtins.map (
          user-name: "d /persist/system/home/${user-name} 0770 ${user-name} users -"
        )
        (
          builtins.attrNames
          config.home-manager.users
        )
      );

    environment.persistence."/persist/system" = let
      chown = user: directory: {
        inherit user directory;
        # group = user;
        mode = "700";
      };
    in {
      # hideMounts = true;
      directories = [
        /*
           {
          # preserve the location of the config
          directory =
            "${config.modules.nixos.core.nixos-cfg-path}";
          # mode = "0777";
        }
        */
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos" # contains user/group id map
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/backlight/" # persist backlight
        "/etc/NetworkManager/system-connections"
        "/srv/restic-repo" # backups

        "/var/cache/tuigreet/" # save last user / session

        # (chown "jellyfin" "/var/lib/jellyfin")
        "/var/lib/jellyfin"
        # also persist cache so we don't have to fetch metadata on every reboot
        "/var/cache/jellyfin"

        "/var/lib/bazarr"
        config.services.radarr.dataDir
        config.services.sonarr.dataDir
        config.services.jackett.dataDir

        # "/etc/ssh" NOTE: this might break things
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
      ];
      files = [
        "/etc/machine-id"
        {
          file = "/var/keys/secret_file";
          parentDirectory = {
            mode = "u=rwx,g=,o=";
          };
        }
      ];
    };
  };
}
