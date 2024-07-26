{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.desktop.sddm;
in {
  options.modules.nixos.os.desktop.sddm =
    mkEnableOpt "enables the sddm login manager";

  config = mkIf cfg.enable {
    services = {
      xserver = enable;

      displayManager.sddm = {
        enable = true;
        # FIXME: (2024-04-07) enable this when it works
        #  currently, when enabled with 3+ monitors connected
        #  it causes systemd to freeze at
        #    "[  ok  ] reached target user and group name lookups"
        #  i think it makes sddm run under wayland
        #  https://discord.com/channels/568306982717751326/1061656643189878874/threads/1226240711431815209
        wayland.enable = true;
      };
    };
  };
}
