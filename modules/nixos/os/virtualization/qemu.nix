{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  inherit (builtins) concatStringsSep;
  cfg = config.modules.nixos.os.virtualization.qemu;
in {
  options.modules.nixos.os.virtualization.qemu =
    mkEnableOpt "enables the qemu for running vm(s)";
  # imports = [inputs.NixVirt.nixosModules.default];
  config = mkIf cfg.enable {
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

    environment.systemPackages = with pkgs; [
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
        "kvm"
        "kvm_amd"
      ];
    };

    # TODO: probably expand this config

    # TODO: add some sort of windows image for compatibility
  };
}
