{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.misc.dconf;
in {
  options.modules.home.misc.dconf = mkEnableOpt "enables ";

  config = mkIf cfg.enable {
    dconf.settings = {
      # this is like a system-wide dark mode switch that some apps respect
      # equivalent of the following dconf command:
      # `conf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"`
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      # tell virt-manager to use the system connection
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
