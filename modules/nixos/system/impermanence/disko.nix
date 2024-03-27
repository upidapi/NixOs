/* {
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt mkOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.impermanence.disko;
in {
  options.modules.nixos.system.impermanence.disko =
    mkEnableOpt "whether or not to enable disko" // {
      device = mkOpt types.str null "the device to be formatted";
      swap = mkOpt types.str "0" "amount of spaw space on the disk";
    };

  imports = [
    inputs.disko.nixosModules.default
  ];

  config = mkIf cfg.enable {
     disko.devices = {
    disk.main = {
      device = cfg.device;
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
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "root_vg";
            };
          };
        } // (if cfg.swap == "0" then {} else {
          swap = {
            size = cfg.swap;
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
        });
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
  };
  };
} */