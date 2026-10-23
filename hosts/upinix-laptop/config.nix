{
  mlib,
  const,
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (const) keys;
  inherit (mlib) enable;
in {
  imports = [
    ./suspend-keyboard-fix.nix
  ];

  system.stateVersion = "23.11";
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems.zfs = lib.mkForce false;
  };

  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #     size = 64 * 1024; # 64 GB
  #   }
  # ];

  # https://github.com/SeniorMatt/Matthew-s-NixOS

  sops.secrets."users/root".neededForUsers = true;
  sops.secrets."users/upidapi".neededForUsers = true;

  hardware = {
    tuxedo-drivers = enable; # doesn't do anything better
    # tuxedo-rs = {
    #   enable = true;
    #   # tailor-gui = enable;
    # };

    nvidia = {
      modesetting.enable = true;

      # power management for dynamic RTX 4060 shutdown (D3cold)
      powerManagement.enable = true;
      powerManagement.finegrained = true;

      # Use proprietary drivers on mobile RTX 40-series to prevent suspend/D3cold bugs
      open = false;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true; # nvidia-offload <app>
        };

        amdgpuBusId = "PCI:6:0:0"; # AMD HawkPoint
        nvidiaBusId = "PCI:1:0:0"; # Nvidia RTX 4060
      };
    };
  };

  powerManagement.powertop.enable = true;

  services = {
    # add deterministic symlink gpu(s)
    udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:06:00.0", SYMLINK="dri/amd-igpu"
      SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="0000:01:00.0", SYMLINK="dri/nvidia-dgpu"
    '';

    power-profiles-daemon.enable = true;
    thermald.enable = lib.mkDefault true;
  };

  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x10"

    # battery things
    "pcie_aspm=force"
    "pcie_aspm.policy=powersave"

    # allow samsung 980 to enter PS4, might cause issues
    # https://wiki.archlinux.org/title/Solid_state_drive/NVMe#Power_management
    "nvme_core.default_ps_max_latency_us=5500"

    # Force S0ix power management
    # save power during suspend
    "nvidia.NVreg_EnableS0ixPowerManagement=1"
  ];

  environment.sessionVariables = {
    # Force Hyprland backend to use the AMD iGpu
    # AQ_DRM_DEVICES = "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu";
    # WLR_DRM_DEVICES = "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu";
    AQ_DRM_DEVICES = "/dev/dri/amd-igpu";
    WLR_DRM_DEVICES = "/dev/dri/amd-igpu";

    XDG_SESSION_TYPE = "wayland";

    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";

    # ensure Wayland apps talk to the AMD graphics driver
    LIBVA_DRIVER_NAME = "radeonsi";
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";

    # force Mesa/Vulkan/Electron apps to use igou
    DRI_PRIME = "pci-0000_06_00_0";

    # Run electron apps with waylans for propper gpu support
    NIXOS_OZONE_WL = "1";
  };

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
  #  which was caused by PROCHOT flag set
  #   a hardware safety thing
  #   that limits clock speed to minimum
  #  Since CPPC is disabled, and PMF fails to init,
  #  therefore linux cant tell AMD SMU to resume to normal power settings
  #   and therefore cant unset the PROCHOT flag
  #  replication: plug out during suspend

  # figure out how to prevent the accidental touches of the touchpad while
  # typing
  # seams to not be an issue anymore, i guess it was a skill issue

  modules.nixos = {
    suites = {
      base = enable;
      # server = enable;
      home = enable;
    };

    virtualisation.waydroid = enable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      upower = enable;

      monitors.monitors = {
        "desc:BOE 0x0C8E" = {
          width = 2560;
          height = 1600;
          refreshRate = 60;
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
