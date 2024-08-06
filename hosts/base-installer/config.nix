# an image made to be as minimal as possible, excluding
# almost everything to remove possible assumptions
# made for testing install scripts
{
  my_lib,
  inputs,
  self,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    # TODO:remove "-no-zfs"
    #  tuxedo required 6.10 (latest kernel)
    #  zfs takes a while to support the latest kernel
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    "${self}/modules/nixos/misc/iso.nix"
  ];

  config = {
    modules.nixos = {
      misc.iso =
        enable
        // {
          name = "base-install";
        };

      nix = {
        cfg-path = "/persist/nixos";
      };

      os = {
        boot = enable;
      };
    };
  };
}
