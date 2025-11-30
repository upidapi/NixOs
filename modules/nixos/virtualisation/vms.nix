{
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkOption types mkEnableOption;
  inherit (inputs) nixvirt;
  nlib = nixvirt.lib;

  cfg = config.modules.nixos.os.virtualisation.vms;
in {
  imports = [
    inputs.nixvirt.nixosModules.default
  ];

  options.modules.nixos.os.virtualisation.vms = {
    enable = mkEnableOption "vms (though libvirt using nixvirt)";
  };

  config = mkIf cfg.enable {
    virtualisation.libvirt = {
      enable = true;

      connections."qemu:///session" = {
        networks = [
          {
            active = true;
            definition = nlib.network.writeXML {
              name = "default";
              uuid = "c4acfd00-4597-41c7-a48e-e2302234fa89";
              forward = {
                mode = "nat";
                nat = {
                  port = {
                    start = 1024;
                    end = 65535;
                  };
                };
              };
              bridge = {name = "virbr0";};
              mac = {address = "52:54:00:02:77:4b";};
              ip = {
                address = "192.168.74.1";
                netmask = "255.255.255.0";
                dhcp = {
                  range = {
                    start = "192.168.74.2";
                    end = "192.168.74.254";
                  };
                };
              };
            };
          }
        ];
      };
    };
  };
}
