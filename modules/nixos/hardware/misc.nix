{
  config,
  lib,
  mlib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.hardware.misc;
in {
  options.modules.nixos.hardware.misc = mkEnableOpt "";

  config = mkIf cfg.enable {
    # Enable all Magic SysRq functions
    # https://en.wikipedia.org/wiki/Magic_SysRq_key
    # alt + sysrq (prtsc) +
    # R - take keyboard control back from Xorg/Wayland
    # E - terminate all processes gracefully (SIGTERM)
    # I - kill remaining unresponsive processes immediately (SIGKILL)
    # S - sync cached data to disk (flush filesystem buffers)
    # U - unmount and remount all filesystems as read-only
    # B - boot/reboot the system immediately
    boot.kernel.sysctl."kernel.sysrq" = 1;
  };
}
