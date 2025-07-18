{
  my_lib,
  keys,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) enable enableAnd disable;
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

      hashedPassword = "$y$j9T$EYMQdTmw82Nd2wnoDxrB10$OGquV37TGBUPTjhQAQ71xCMtmo3y0mnQiznUbME4UT3";

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

    root.hashedPassword = "$y$j9T$kV/aEFz0la0QtThvK5Ghp1$oxghtnjsA0mSXrM62uY99l7ijDIN5tIFynkKhNcEOP0";
  };
  # optimise for battery
  #     green: efficiency
  #     purple: balanced
  #     blue: performance

  hardware = {
    # tuxedo-drivers = enable; # doesn't do anything better
    # tuxedo-rs = {
    #   enable = true;
    #   tailor-gui = enable;
    # };
  };

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

  # FIXME: figure out how to prevent the accidental touches of the touchpad
  #  while typing

  modules.nixos = {
    suites.all = enable;

    homelab = {
      transfer-sh = enable; # TODO: remove, this is for debug
      media = enableAnd {
        jellyfin = enable;
        jellyseerr = enable;
        arr = enable;
      };
    };

    os.services.syncthing = disable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

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
