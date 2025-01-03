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
  home-persist = "/persist/system/home/${config.home.username}/persist";
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

    virtualisation.libvirt = {
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
          definition = nlib.pool.getXML {
            name = "home";
            uuid = "fef60081-fb06-47f2-aa34-f23e1ec12dbc";
            type = "dir";
            target = {
              path = "${home-persist}/vms/storage/";
            };
          };
          volumes = [
            (mkIf cfg.w11 {
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
