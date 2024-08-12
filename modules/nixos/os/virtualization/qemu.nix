{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualization.qemu;
in {
  options.modules.nixos.os.virtualization.qemu =
    mkEnableOpt "enables the qemu for running vm(s)";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # (writeScriptBin "iommu-groups" ''
      # #!/usr/bin/env bash
      # shopt -s nullglob
      # for g in $(find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V); do
      #     echo "IOMMU Group ''${g##*/}:"
      #     for d in $g/devices/*; do
      #         echo -e "\t$(lspci -nns ''${d##*/})"
      #     done;
      # done;
      # '')

      # various os(s) vm images that can be started with one command
      quickemu

      # frontend for libvirt
      virt-manager

      # VGA PCI Pass-through without an attached physical monitor,
      # keyboard or mouse.
      looking-glass-client
    ];

    virtualisation.libvirtd = {
      enable = true;
      qemu.ovmf = enable;
      onBoot = "ignore";
      onShutdown = "shutdown";
      hooks.qemu = {
        events = ./virtualisation_events.sh;
      };
    };
    programs.virt-manager.enable = true;

    # based on https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
    # and https://github.com/nimueller/dotfiles/blob/main/nixos/hosts/desktop/virtualisation.nix

    systemd.tmpfiles.rules = [
      # TODO: generalise
      "f /dev/shm/looking-glass 0660 upidapi kvm -"
    ];

    # referance
    boot = {
      kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"

        "kvm"
        "kvm_amd"
      ];
      # kernelParams = [ "intel_iommu=on" "iommu=pt" "vfio-pci.ids=1002:6fdf,1002:aaf0" "hugepages=8192" ];

      # proprietary nvidia drivers
      extraModprobeConfig = "softdep nvidia pre: vfio-pci";
      # else
      # extraModprobeConfig = "softdep drm pre: vfio-pci";

      # intel_iommu=on for intel chips
      # maybe add params based on nixos/hardware
      # nix-mineral sets it to force isolation
      kernelParams = [
        "iommu=pt"
        "amd_iommu=on"
        "intel_iommu=on"

        # specify the IDs of the devices you intend to passthrough
        # (this is hardware specific)
        # 01:00.0 VGA compatible controller [0300]: NVIDIA Corporation TU116 [GeForce GTX 1660 Ti] [10de:2182] (rev a1)
        # 01:00.1 Audio device [0403]: NVIDIA Corporation TU116 High Definition Audio Controller [10de:1aeb] (rev a1)
        # 01:00.2 USB controller [0c03]: NVIDIA Corporation TU116 USB 3.1 Host Controller [10de:1aec] (rev a1)
        # 01:00.3 Serial bus controller [0c80]: NVIDIA Corporation TU116 USB Type-C UCSI Controller [10de:1aed] (rev a1)
        ''vfio-pci.ids=${builtins.concatStringsSep "," [
            "10de:2182"
            "10de:1aeb"
            "10de:1aec"
            "10de:1aed"
          ]}''
      ];
    };

    # Dont forget to enable iommu in the bios
    # for me (on amd) auto didn't work

    # TODO: probably expand this config

    # TODO: add some sort of windows image for compatibility
  };
}
