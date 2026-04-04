{
  mlib,
  const,
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (const) keys;
  inherit (mlib) enable enableAnd;
in {
  imports = [
    ./suspend-keyboard-fix.nix
  ];

  system.stateVersion = "23.11";

  boot = {
    # This seams to not be the case:
    #   i think that the update from 6.12.4 to 6.12.5 broke suspend
    #     but using the 6.11 kernel didn't seam to fix it
    # kernelPackages = pkgs.linuxPackages_6_11;
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems.zfs = lib.mkForce false;
  };

  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #     size = 64 * 1024; # 64 GB
  #   }
  # ];

  # performance/battery optimisation
  # https://github.com/SeniorMatt/Matthew-s-NixOS

  # the performance issues (low clock speeds) seem to disappear when charging
  # (possibly to full)

  sops.secrets."users/root".neededForUsers = true;
  sops.secrets."users/upidapi".neededForUsers = true;

  users.users = {
    upidapi = {
      isNormalUser = true;

      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
        "adbusers"
        "docker"
        "media"
      ];

      hashedPasswordFile = config.sops.secrets."users/upidapi".path;

      openssh.authorizedKeys.keys = [keys.users.upidapi];
    };

    debug = {
      isNormalUser = true;
      password = "";
      openssh.authorizedKeys.keys = [keys.users.upidapi];
    };

    debug-1 = {
      isNormalUser = true;
      password = "1";
      openssh.authorizedKeys.keys = [keys.users.upidapi];
    };

    root.hashedPasswordFile = config.sops.secrets."users/root".path;
  };
  # optimise for battery
  #   green: efficiency
  #   purple: balanced
  #   blue: performance

  # NOTE: fix the 544MHz locking after suspend
  # which was caused by PROCHOT flag set
  #   a hardware safety thing
  #   that limits clock speed to minimum
  # Since CPPC is disabled, and PMF fails to init,
  # therefore linux cant tell AMD SMU to resume to normal power settings
  #   and therefore cant unset the PROCHOT flag
  # replication: plug out during suspend
  hardware = {
    tuxedo-drivers = enable; # doesn't do anything better
    # tuxedo-rs = {
    #   enable = true;
    #   # tailor-gui = enable;
    # };
  };

  services.thermald.enable = lib.mkDefault true;

  # probably fixes it
  # (2025-03-14) Randomly after a while my pc starts to lag (like 1fps)
  #  and the tty is no better
  #   https://chatgpt.com/c/67d44dfe-939c-800b-9564-fd1d3f020feb
  #   https://community.frame.work/t/kworker-events-unbound-stuck-at-100-cpu-laptop-slows-to-1-fps/63464/6
  #   https://bbs.archlinux.org/viewtopic.php?id=302615
  #  started a few days ago, probably the update from 6.13.4 -> 6.13.6
  #  might be a temp fix
  #   cat /sys/kernel/debug/dri/1/amdgpu_gpu_recover

  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"
  ];

  # figure out how to prevent the accidental touches of the touchpad while
  # typing
  # seams to not be an issue anymore, i guess it was a skill issue

  modules.nixos = {
    # homelab.media = {
    #   enable = true;
    #   qbit = enable;
    # };
    #
    # networking.vpn.namespaces = enableAnd {
    #   proton = true;
    # };

    suites = {
      base = enable;
      # server = enable;
      home = enable;
    };

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      upower = enable;

      monitors.monitors = {
        "desc:BOE 0x0C8E" = {
          width = 2560;
          height = 1600;
          refreshRate = 240;
          x = 0;
          y = 0;
          scale = 1.333333;

          workspace = 1;
          primary = true;
        };
      };
    };
  };
}
