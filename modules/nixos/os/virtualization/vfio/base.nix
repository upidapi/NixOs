{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.virtualisation.vfio;
  hardwareCfg = config.nixos.modules.hardware;
in {
  options.virtualisation.vfio = {
    enable = mkEnableOption "VFIO Configuration";

    devices = mkOption {
      type = types.listOf (types.strMatching "[0-9a-f]{4}:[0-9a-f]{4}");
      default = [];
      example = ["10de:1b80" "10de:10f0"];
      description = "PCI IDs of devices to bind to vfio-pci";
    };
    disableEFIfb = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Disables the usage of the EFI framebuffer on boot.";
    };
    blacklistNvidia = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Add Nvidia GPU modules to blacklist";
    };
    ignoreMSRs = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = "Enables or disables kvm guest access to model-specific registers";
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"
    '';

    boot = {
      kernelParams =
        (optionals hardwareCfg.cpu.intel [
          "intel_iommu=on"
          "intel_iommu=igfx_off"
        ])
        ++ (optionals hardwareCfg.cpu.amd [
          # nix-mineral sets it to force-isolation why?
          "amd_iommu=on"
        ])
        ++ (optionals cfg.ignoreMSRs [
          "kvm.ignore_msrs=1"
          "kvm.report_ignored_msrs=0"
        ])
        ++ (
          optional (builtins.length cfg.devices > 0) (
            "vfio-pci.ids=" + builtins.concatStringsSep "," cfg.devices
          )
        )
        ++ (optional cfg.disableEFIfb "video=efifb:off");

      # custom (might break things)
      extraModprobeConfig =
        if hardwareCfg.gpu.nvidia
        # proprietary nvidia drivers
        then "softdep nvidia pre: vfio-pci"
        # else
        else "softdep drm pre: vfio-pci";

      initrd.kernelModules =
        [
          "vfio_pci"
          "vfio_iommu_type1"
          "vfio"
        ]
        ++ lib.optional (
          lib.versionOlder pkgs.linux.version "6.2"
        ) "vfio_virqfd";

      blacklistedKernelModules = optionals cfg.blacklistNvidia [
        "nvidia"
        "nouveau"
      ];
    };
  };
}
