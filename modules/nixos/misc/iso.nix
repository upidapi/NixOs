{
  lib,
  config,
  self,
  my_lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkImageMediaOverride mkIf mkOption types;
  cfg = config.modules.nixos.misc.iso;
in {
  options.modules.nixos.misc.iso =
    mkEnableOpt "enables iso stuff"
    // {
      name = mkOption {
        default = config.modules.nixos.meta.host-name;
        type = types.str;
      };
    };

  config = mkIf cfg.enable {
    isoImage = let
      hostname = config.modules.nixos.misc.iso.name;
      rev = self.shortRev or "${builtins.substring 0 8 self.lastModifiedDate}-d";
      # $hostname-$release-$rev-$arch
      # rel = config.system.nixos.release;
      arch = pkgs.stdenv.hostPlatform.uname.processor;
      name = "${hostname}-${rev}-${arch}";
    in {
      isoName = mkImageMediaOverride "${name}.iso";
      volumeID = mkImageMediaOverride "${name}";

      # TODO: is the tradeof worth it?
      #  default: 5.3 GB, mod: 6.7 GB
      # The default compression-level is (6) and takes too long on some machines (>30m).
      # 3 takes <2m
      squashfsCompression = "zstd -Xcompression-level 3";
    };

    nixpkgs = {
      hostPlatform =
        /*
        lib.mkDefault
        */
        "x86_64-linux";
      config.allowUnfree = true;
    };

    # its an iso so it doesn't have to be preserved
    # system.stateVersion = "23.11";

    # done by the imports
    /*

    users.users.root.initialHashedPassword = "";

    users.users.nixos = {
      isNormalUser = true;
      description = "nixos";

      extraGroups = ["networkmanager" "wheel"];

      initialHashedPassword = "";
    };
    */
    # hardware.tuxedo-keyboard = enable;
  };
}
