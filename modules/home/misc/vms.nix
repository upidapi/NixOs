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
        default = "win11_24h2_englishinternational_x64.iso";
      };
    };
  };

  config = mkIf cfg.enable {
    # tell virt-manager to use the system connection
    dconf.settings."org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };

    # REF: https://github.com/Svenum/holynix/blob/295a24e8e2f97298f21e8b2d0112ed8cb919b657/systems/x86_64-linux/Yon/kvm.nix#L134

    # NOTE: the config is located at .config/libvirt/qemu
    #  and the virt-manager is located at /var/lib/libvirt/

    # Make it show up in virt[-manager]
    # virsh define .config/libvirt/qemu/w11.xml
    # If using the cli you can instead use "-c qemu:///session"

    # Start vm in cli
    # virsh pool-start w11
    # virsh start w11

    # virsh destroy w11

    # if this doesn't exist then libvirt chrashes and since its
    # a part of the home-manager activation script it too chrashes
    home.activation.createVmDirs = lib.hm.dag.entryBefore ["NixVirt"] ''
      mkdir -p ${home-persist}/vms/storage
      mkdir -p ${home-persist}/vms/iso
    '';

    virtualisation.libvirt = {
      enable = true;

      swtpm.enable = true;

      connections."qemu:///session".domains = [
        (mkIf cfg.w11.enable {
          definition = nlib.domain.writeXML (
            lib.recursiveUpdate (
              nlib.domain.templates.windows rec {
                name = "w11";
                uuid = "def734bb-e2ca-44ee-80f5-0ea0f2593aaa";
                memory = {
                  count = 16;
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
            }
          );
        })
      ];

      connections."qemu:///session".pools = [
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
    };
  };
}
