{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.hardware.gpu.nvidia;
in {
  options.modules.nixos.hardware.gpu.nvidia =
    mkEnableOpt "enables nvidia gpu drivers for the system";

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"]; # this breaks stuff (cursor disappears)

    environment.variables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    hardware.nvidia = {
      # Modesetting is needed most of the time
      modesetting.enable = true;

      # Enable power management
      # (do not disable this unless you have a reason to)# .
      # Likely to cause problems on laptops and with screen tearing if disabled.
      powerManagement.enable = true;

      # Use the NVidia open source kernel module (which isn't “nouveau”).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      # open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.production;

      # FIXME: (2025-01-15 23:05:20) currently breaks suspend
      # open = true
      open = false;

      # optimus prime
      # if you have and Nvidia GPU in a laptop you need to enable the following
      # find your bus IDs using lshw

      # prime = {
      #   intelBusId = "PCI:0:0:0";
      #   nvidiaBusId = "PCI:0:0:0";
      #   sync.enable = true;
      # };
    };
  };
}
