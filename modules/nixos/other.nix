{
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.other;
in {
  options.modules.nixos.other =
    mkEnableOpt "enables config that i've not found a place for";

  # TODO: put thease things into it's own modules
  config = mkIf cfg.enable {
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # this just makes the user own /persist/nixos
    systemd.tmpfiles.settings = {
      # i believe that that name is arbitrary (10-mypackage)
      "set-cfg-perm" = {
        "${config.modules.nixos.system.nix.cfg-path}" = {
          z = {
            group = "wheel";
            mode = "0775";
          };
        };
      };
    };

    # virtualisation
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
