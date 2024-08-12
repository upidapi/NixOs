{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualization.qemu;
in {
  options.modules.nixos.os.virtualization.qemu =
    mkEnableOpt "enables the qemu for running vm(s)";

  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # referance
    # boot.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" "kvm" "kvm_amd" ];
    # boot.kernelParams = [ "intel_iommu=on" "iommu=pt" "vfio-pci.ids=1002:6fdf,1002:aaf0" "hugepages=8192" ];
    # boot.extraModprobeConfig = "softdep drm pre: vfio-pci";

    # intel_iommu=on for intel chips
    # maybe add params based on nixos/hardware
    # nix-mineral sets it to force isolation
    boot.kernelParams = ["amd_iommu=on"];

    # TODO: probably expand this config

    # TODO: add some sort of windows image for compatibility
  };
}
