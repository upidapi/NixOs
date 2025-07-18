# taken from notashelf
{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualisation.waydroid;
  waydroid-ui = pkgs.writeShellScriptBin "waydroid-ui" ''
    export WAYLAND_DISPLAY=wayland-0
    ${pkgs.weston}/bin/weston -Swayland-1 --width=600 --height=1000 --shell="kiosk-shell.so" &
    WESTON_PID=$!

    export WAYLAND_DISPLAY=wayland-1
    ${pkgs.waydroid}/bin/waydroid show-full-ui &

    wait $WESTON_PID
    waydroid session stop
  '';
in {
  options.modules.nixos.os.virtualisation.waydroid =
    mkEnableOpt "enables waydroid (android on wayland)";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      waydroid
      waydroid-ui
    ];

    virtualisation = {
      lxd = enable;
      waydroid = enable;
    };
  };
}
