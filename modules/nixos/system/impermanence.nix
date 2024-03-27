{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.system.impermanence;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.modules.nixos.system.impermanence =
    mkEnableOpt "enables impermanence";

  config = mkIf cfg.enable {
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

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      {
        # preserve the location of the config
        directory = 
          "${config.modules.nixos.core.nixos-cfg-path}";
        # mode = "0777";
      }
      
      "/var/log" 
      "/var/lib/bluetooth" # for saving bth devices
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { 
        directory = "/var/lib/colord"; 
        user = "colord"; 
        group = "colord"; 
        mode = "u=rwx,g=rx,o="; 
      }
    ];
    files = [
      # todo: fix this
      # "/etc/machine-id"
      { 
        file = "/var/keys/secret_file"; 
        parentDirectory = { 
          mode = "u=rwx,g=,o="; 
          }; 
        }
    ];
  };

  # required by home manager impermanance  
  programs.fuse.userAllowOther = true;

  };
}
