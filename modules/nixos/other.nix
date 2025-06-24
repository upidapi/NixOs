{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.other;
in {
  options.modules.nixos.other =
    mkEnableOpt "enables config that i've not found a place for";

  config = mkIf cfg.enable {
    # for bios updates
    services.fwupd = enable;

    # TODO: remove, see https://github.com/NixOS/nixpkgs/issues/404663
    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-1.1.05"
    ];

    # maybe make some gnome things work
    programs.dconf.enable = true;
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
    ];

    # fixes
    # (arr-init)[42900]: Directory "/var/lib/private" already exists, but has mode 0755 that is too permissive (0700 was requested), refusing.
    # manual fix
    # chmod 700 -R /var/lib/private/; chown root:root -R /var/lib/private; scl restart prowlarr; scl restart jellyseerr
    # i think this comes from the persistence module creating subdirs with -p
    systemd.tmpfiles.settings = {
      "fix-var-lib-private-perms" = {
        "/var/lib/private".d = {
          group = "root";
          user = "root";
          mode = "700";
        };
      };
    };
  };
}
