{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkOption types mkEnableOption trace;
  inherit (inputs) nixvirt;
  nlib = nixvirt.lib;

  cfg = config.modules.home.misc.vms;
  home-persist = "/persist/system/home/${config.home.username}/persist";
in {
  imports = [
    inputs.nixvirt.homeModules.default
  ];

  options.modules.home.misc.vms = {
    enable = mkEnableOption "vms (though libvirt using nixvirt)";
    w11 = {
      enable = mkEnableOption ''
        Adds a windows 11 vm to virt manager.
        Note you need to place a iso in the right place.
      '';
      isoName = mkOption {
        description = "the name of the iso in ~/persist/vms/isos";
        type = types.str;
        default = "Win11_24h2_EnglishInternational_x64.iso";
      };
    };
  };

  config = mkIf cfg.enable {
    # tell virt-manager to use the system connection
    dconf.settings."org/virt-manager/virt-manager/connections" = {
      # TODO: add "qemu:///session"?
      autoconnect = [
        "qemu:///system"
        "qemu:///session"
      ];
      uris = [
        "qemu:///system"
        "qemu:///session"
      ];
    };

    # REF: https://github.com/Svenum/holynix/blob/295a24e8e2f97298f21e8b2d0112ed8cb919b657/systems/x86_64-linux/Yon/kvm.nix#L134

    # NOTE: the config is located at .config/libvirt/qemu
    #  and the virt-manager is located at /var/lib/libvirt/

    # if this doesn't exist then libvirt chrashes and since its
    # a part of the home-manager activation script it too chrashes
    home.activation.createVmDirs = lib.hm.dag.entryBefore ["NixVirt"] ''
      mkdir -p ${home-persist}/vms/storage
      mkdir -p ${home-persist}/vms/isos
      mkdir -p ${home-persist}/vms/nvram
    '';

    virtualisation.libvirt = {
      enable = true;

      swtpm.enable = true;

      connections."qemu:///session" = {
        domains = [
          (mkIf cfg.w11.enable {
            definition = nlib.domain.writeXML (
              lib.recursiveUpdate (
                nlib.domain.templates.windows rec {
                  name = "w11";
                  uuid = "def734bb-e2ca-44ee-80f5-0ea0f2593aaa";
                  memory = {
                    count = 10;
                    unit = "GiB";
                  };
                  storage_vol = {
                    pool = "home";
                    volume = "${name}.qcow2";
                  };
                  install_vol = "${home-persist}/vms/isos/${cfg.w11.isoName}";
                  nvram_path = "${home-persist}/vms/nvram/${name}.fd";
                  virtio_net = true;
                  virtio_drive = true;
                  install_virtio = true;
                }
              )
              {
                # without this it fails with
                # "conversion of the nvram template to another target format is
                # not supported"
                os.nvram.templateFormat = "raw";

                # memoryBacking = {
                #   source.type = "memfd";
                #   access.mode = "shared";
                # };
                #
                # devices.filesystem = [
                #   {
                #     type = "mount";
                #     accessmode = "passthrough";
                #     driver = {
                #       type = "virtiofs";
                #     };
                #     source = {
                #       dir = "/home/${user}/music";
                #     };
                #     target = {
                #       dir = "music";
                #     };
                #   }
                # ];
              }
            );
          })
        ];

        pools = [
          {
            active = true;
            definition = nlib.pool.writeXML {
              name = "home";
              uuid = "ac82824e-567a-43f2-8915-644f4809f540";
              type = "dir";
              target = {
                path = "${home-persist}/vms/storage/";
              };
            };
            volumes = [
              (mkIf cfg.w11.enable {
                present = true;
                definition = nlib.volume.writeXML {
                  name = "w11.qcow2";
                  capacity = {
                    count = 100;
                    unit = "GiB";
                  };
                  target = {
                    format.type = "qcow2";
                  };
                };
              })
            ];
          }
        ];

        # cant figure out how to connect to the system network
        # networks = [
        #   {
        #     active = true;
        #     definition = nlib.network.writeXML {
        #       name = "default";
        #       uuid = "c4acfd00-4597-41c7-a48e-e2302234fa89";
        #       forward = {
        #         mode = "nat";
        #         nat = {
        #           port = {
        #             start = 1024;
        #             end = 65535;
        #           };
        #         };
        #       };
        #       bridge = {name = "virbr0";};
        #       mac = {address = "52:54:00:02:77:4b";};
        #       ip = {
        #         address = "192.168.74.1";
        #         netmask = "255.255.255.0";
        #         dhcp = {
        #           range = {
        #             start = "192.168.74.2";
        #             end = "192.168.74.254";
        #           };
        #         };
        #       };
        #     };
        #   }
        # ];
      };
    };
  };
}
