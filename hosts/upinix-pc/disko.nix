# https://github.com/sodiboo/system/blob/3d970bb172a908e95c46ca097337f858a5f5ad66/core/disko.mod.nix#L31
# https://github.com/DavHau/hyperconfig/blob/cf7943b64d5011e03f10570e46ea815e114a92f9/machines/manu-nas/disko-config.nix#L97
{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5SVNG0N990909T";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            /*
            swap = {
              size = "4G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            */
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
          };
        };
      };
      raid-disk-1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST18000NM003D-3DL103_ZVTAZSKF";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "raidpool";
              };
            };
          };
        };
      };
      raid-disk-2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ST18000NM003D-3DL103_ZVT9SZNJ";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "raidpool";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];

              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };

                "/persist" = {
                  mountOptions = ["subvol=persist" "noatime"];
                  mountpoint = "/persist";
                };

                "/nix" = {
                  mountOptions = ["subvol=nix" "noatime"];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      raidpool = {
        type = "zpool";
        mode = "raidz";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = null;
        postCreateHook = "zfs snapshot raidpool@blank";

        datasets = {
          raidset = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/raid";
          };
        };
      };
    };
  };
}
