{
  config,
  lib,
  my_lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (my_lib.opt) mkEnableOpt;
  inherit (inputs) nixvirt;
  nlib = nixvirt.lib;

  cfg = config.modules.home.misc.vms;
  home-persist = "/home/${config.home.username}/test";
in {
  imports = [
    inputs.nixvirt.homeModules.default
  ];

  options.modules.home.misc.vms =
    (mkEnableOpt "enable vms (trough libvirt)")
    // {
      w11 = mkOption {
        description = ''
          Adds a windows 11 vm to virt manager.
          Note you need to place a iso in the right place.
        '';
        type = types.bool;
        default = false;
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

    virtualisation.libvirt = {
      enable = true;

      swtpm.enable = true;

      connections."qemu:///session".domains = [
        (mkIf cfg.w11 {
          definition = nlib.domain.writeXML (nlib.domain.templates.windows
            rec {
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
              install_vol = "${home-persist}/vms/isos/Win11_24H2_EnglishInternational_x64.iso";
              nvram_path = "${home-persist}/vms/storage/${name}.nvram";
              virtio_net = true;
              virtio_drive = true;
              install_virtio = true;
            });
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
            (mkIf cfg.w11 {
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
