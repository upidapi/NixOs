{
  config,
  my_lib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualisation.qemu;
in {
  options.modules.nixos.os.virtualisation.qemu =
    mkEnableOpt "enables the qemu for running vm(s)";

  imports = [inputs.nixvirt.nixosModules.default];

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
      # BROKEN: fixed by https://github.com/NixOS/nixpkgs/pull/369622
      quickemu

      # frontend for libvirt
      virt-manager

      # VGA PCI Pass-through without an attached physical monitor,
      # keyboard nor mouse.
      # BROKEN:  https://github.com/NixOS/nixpkgs/pull/369556
      looking-glass-client
    ];

    # REF: https://github.com/Lillecarl/nixos/blob/ba287ceaf13ee9ceb940db6454838582959c5d3e/hosts/_shared/libvirt.nix#L25
    virtualisation.libvirtd = {
      enable = true;

      qemu = {
        # does this do anything?
        package = pkgs.qemu_kvm;

        # passthrugh stuff
        ovmf = {
          enable = true;

          # Include OVMF_CODE.secboot.fd
          packages = [pkgs.OVMFFull.fd];
        };

        # virtual tpm
        swtpm = enable;

        # maybe
        # vhostUserPackages = [
        #   pkgs.virtiofsd
        # ];
      };

      onBoot = "ignore";
      onShutdown = "shutdown";
      hooks.qemu = {
        events = ./virtualisation_events.sh;
      };
    };

    virtualisation.spiceUSBRedirection.enable = true;

    programs.virt-manager.enable = true;

    # REF: https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF
    # REF: https://github.com/nimueller/dotfiles/blob/main/nixos/hosts/desktop/virtualisation.nix

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 root kvm -"
    ];

    boot = {
      kernelModules = [
        "kvm"
        "kvm_amd"
      ];
    };
  };
}
/*
for windows 11

TIS 2.0
*/

